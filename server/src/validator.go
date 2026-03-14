package main

import (
	"errors"
	"time"
)

func IsValidDate(year, month, day int) error {
	if year < minYear {
		return errors.New("неправильный год")
	}
	if year == minYear {
		if month < minMonth {
			return errors.New("неправильный месяц")
		}
		if month == minMonth && day < minDay {
			return errors.New("неправильный день")
		}
	}

	if month < 1 || month > 12 {
		return errors.New("неправильный месяц")
	}

	if !isValidDay(year, month, day) {
		return errors.New("неправильный день")
	}

	dateToCheck := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.UTC)
	if dateToCheck.Year() != year || dateToCheck.Month() != time.Month(month) || dateToCheck.Day() != day {
		return errors.New("неправильная дата")
	}

	now := time.Now().UTC()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)

	if dateToCheck.After(today) {
		return errors.New("неправильная дата")
	}
	return nil
}

func isValidDay(year, month, day int) bool {
	if day < 1 {
		return false
	}

	daysInMonth := [12]int{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

	if month == 2 && isLeapYear(year) {
		daysInMonth[1] = 29
	}

	return day <= daysInMonth[month-1]
}

func isLeapYear(year int) bool {
	return year%4 == 0 && (year%100 != 0 || year%400 == 0)
}
