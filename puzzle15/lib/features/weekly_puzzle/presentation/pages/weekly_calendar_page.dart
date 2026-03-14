import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/di/injection_container.dart';
import 'package:puzzle15/core/puzzle/calendar.dart';
import 'package:puzzle15/core/widgets/settings_action_button.dart';
import '../bloc/weekly_calendar_bloc.dart';

class WeeklyCalendarPage extends StatelessWidget {
  const WeeklyCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WeeklyCalendarBloc>()..add(WeeklyCalendarStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Еженедельные задания'),
          actions: const [SettingsActionButton()],
        ),
        body: BlocBuilder<WeeklyCalendarBloc, WeeklyCalendarState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.failure != null) {
              return Center(child: Text(state.failure!.message));
            }

            final visibleMonth = state.visibleMonth ?? DateTime.now();
            final monthLabel = DateFormat.yMMMM('ru_RU').format(visibleMonth);
            final completedCount = state.days.where((e) => e.completed).length;
            final calendarDays = CalendarUtils.getDaysInMonthGrid(
              visibleMonth.year,
              visibleMonth.month,
            );
            final weekNumber = calendarDays.length / 7;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.read<WeeklyCalendarBloc>().add(
                          WeeklyCalendarMonthChanged(
                            visibleMonth.year,
                            visibleMonth.month - 1,
                          ),
                        ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              monthLabel,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Пройдено: $completedCount из ${state.days.length}',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.read<WeeklyCalendarBloc>().add(
                          WeeklyCalendarMonthChanged(
                            visibleMonth.year,
                            visibleMonth.month + 1,
                          ),
                        ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('ПН'),
                      Text('ВТ'),
                      Text('СР'),
                      Text('ЧТ'),
                      Text('ПТ'),
                      Text('СБ'),
                      Text('ВС'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = min(
                        (constraints.maxWidth - (7 * 8 * 2)) / 7,
                        (constraints.maxHeight - (weekNumber * 8 * 2)) /
                            weekNumber,
                      );

                      return Center(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.0,
                                mainAxisExtent: cellSize,
                              ),
                          itemCount: calendarDays.length,
                          itemBuilder: (context, index) {
                            final item = calendarDays[index];
                            if (!item.current || state.days.length < item.day) {
                              return Center(
                                child: Text(
                                  "${item.day}",
                                  style: TextStyle(
                                    color: Color.from(
                                      alpha: 1,
                                      red: 0.7,
                                      green: 0.7,
                                      blue: 0.7,
                                    ),
                                    fontWeight: item.current
                                        ? FontWeight.bold
                                        : FontWeight.w100,
                                  ),
                                ),
                              );
                            }

                            final curItem = state.days[item.day - 1];
                            final selected = state.selectedDate == curItem.date;
                            return Container(
                              height: cellSize,
                              width: cellSize,
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () =>
                                    context.read<WeeklyCalendarBloc>().add(
                                      WeeklyCalendarDaySelected(curItem.date),
                                    ),
                                borderRadius: BorderRadius.circular(9999),
                                child: Container(
                                  height: cellSize,
                                  width: cellSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: curItem.completed
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.green,
                                        )
                                      : Text(
                                          '${curItem.date.day}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Color.from(
                                              alpha: 1,
                                              red: 0.2,
                                              green: 0.2,
                                              blue: 0.2,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (state.selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Builder(
                          builder: (_) {
                            final selected = state.days.firstWhere(
                              (e) => e.date == state.selectedDate,
                            );
                            if (!selected.completed)
                              return const SizedBox.shrink();
                            return Text(
                              'Пройдено за ${selected.seconds} сек, ходов: ${selected.moves}',
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              final date = state.selectedDate ?? DateTime.now();
                              final res = await Navigator.pushNamed(
                                context,
                                AppRouter.weeklyLoader,
                                arguments: date,
                              );
                              if (context.mounted && res == true) {
                                context.read<WeeklyCalendarBloc>().add(
                                  WeeklyCalendarFinishedGame(date),
                                );
                              }
                            },
                            child: const Text('Играть'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
