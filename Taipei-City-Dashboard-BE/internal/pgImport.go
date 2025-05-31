package internal

import (
	"errors"
	"fmt"
	"log"
	"regexp"
	"strconv"
	"strings"
	"time"

	"gorm.io/gorm"
)

const (
	DB_TYPE_INTEGER                     = "INTEGER"
	DB_TYPE_NUMERIC                     = "NUMERIC"
	DB_TYPE_DOUBLE_PRECISION            = "DOUBLE PRECISION"
	DB_TYPE_TIMESTAMP_WITH_TIME_ZONE    = "TIMESTAMP WITH TIME ZONE"
	DB_TYPE_TIMESTAMP_WITHOUT_TIME_ZONE = "TIMESTAMP WITHOUT TIME ZONE"
	DB_TYPE_TEXT                        = "TEXT"
)

var tzRegex = regexp.MustCompile(`(?i)(z|[+-]\d{2}:\d{2})$`)

// PGImport imports a CSV-like data into a newly created Postgres table
func PGImport(db *gorm.DB, data [][]string, tableName, schemaName string) error {
	if len(data) == 0 {
		return errors.New("no data provided")
	}

	header := data[0]
	if len(header) == 0 {
		return errors.New("CSV header is empty")
	}

	sampleRows := data[1:]
	if len(sampleRows) > 100 {
		sampleRows = sampleRows[:100]
	}

	inferredTypes := inferColumnTypes(header, sampleRows)
	log.Printf("debug: inferred types: %v\n", inferredTypes)

	// Build and execute CREATE TABLE
	columnDefs := []string{`"id" SERIAL PRIMARY KEY`}
	for i, col := range header {
		columnDef := fmt.Sprintf(`"%s" %s`, col, inferredTypes[i])
		columnDefs = append(columnDefs, columnDef)
	}
	createStmt := fmt.Sprintf(`CREATE TABLE "%s"."%s" (%s);`, schemaName, tableName, strings.Join(columnDefs, ", "))

	if err := db.Exec(createStmt).Error; err != nil {
		return fmt.Errorf("failed to create table: %w", err)
	}
	log.Printf("debug: table '%s' created", tableName)

	// Insert rows
	for _, record := range data[1:] {
		if len(record) != len(header) {
			continue
		}
		typedRow := convertRow(record, inferredTypes)
		placeholders := make([]string, len(typedRow))
		values := make([]any, len(typedRow))
		for i, val := range typedRow {
			// $1, $2, ...
			placeholders[i] = fmt.Sprintf("$%d", i+1)
			values[i] = val
		}
		insertSQL := fmt.Sprintf(`INSERT INTO "%s"."%s" (%s) VALUES (%s)`,
			schemaName,
			tableName,
			strings.Join(wrapWithQuotes(header), ", "),
			strings.Join(placeholders, ", "))
		if err := db.Exec(insertSQL, values...).Error; err != nil {
			return fmt.Errorf("failed to insert row: %w", err)
		}
	}
	log.Printf("debug: %d rows inserted to database", len(data)-1)

	return nil
}

func wrapWithQuotes(cols []string) []string {
	out := make([]string, len(cols))
	for i, col := range cols {
		out[i] = `"` + col + `"`
	}
	return out
}

func inferColumnTypes(header []string, sampleRows [][]string) []string {
	priorities := map[string]int{
		DB_TYPE_INTEGER:                     1,
		DB_TYPE_NUMERIC:                     2,
		DB_TYPE_DOUBLE_PRECISION:            2,
		DB_TYPE_TIMESTAMP_WITH_TIME_ZONE:    3,
		DB_TYPE_TIMESTAMP_WITHOUT_TIME_ZONE: 4,
		DB_TYPE_TEXT:                        5,
	}
	result := make([]string, len(header))
	for i := range header {
		bestPriority := 0
		bestType := DB_TYPE_TEXT
		for _, row := range sampleRows {
			if i >= len(row) {
				continue
			}
			t := inferPgType(strings.TrimSpace(row[i]))
			if priorities[t] > bestPriority {
				bestPriority = priorities[t]
				bestType = t
			}
		}
		result[i] = bestType
	}
	return result
}

func inferPgType(value string) string {
	if _, err := strconv.Atoi(value); err == nil {
		return DB_TYPE_INTEGER
	}
	if _, err := strconv.ParseFloat(value, 64); err == nil {
		return DB_TYPE_NUMERIC
	}
	if _, err := time.Parse(time.RFC3339, value); err == nil {
		if hasTimeZone(value) {
			return DB_TYPE_TIMESTAMP_WITH_TIME_ZONE
		}
		return DB_TYPE_TIMESTAMP_WITHOUT_TIME_ZONE
	}
	return DB_TYPE_TEXT
}

func hasTimeZone(s string) bool {
	return tzRegex.MatchString(s)
}

func convertRow(values []string, types []string) []any {
	result := make([]any, len(values))
	for i, val := range values {
		val = strings.TrimSpace(val)
		if val == "" {
			result[i] = nil
			continue
		}
		switch types[i] {
		case DB_TYPE_INTEGER:
			if v, err := strconv.Atoi(val); err == nil {
				result[i] = v
			} else {
				result[i] = nil
			}
		case DB_TYPE_NUMERIC:
		case DB_TYPE_DOUBLE_PRECISION:
			if v, err := strconv.ParseFloat(val, 64); err == nil {
				result[i] = v
			} else {
				result[i] = nil
			}
		case DB_TYPE_TIMESTAMP_WITHOUT_TIME_ZONE:
		case DB_TYPE_TIMESTAMP_WITH_TIME_ZONE:
			if v, err := time.Parse(time.RFC3339, val); err == nil {
				result[i] = v
			} else {
				result[i] = nil
			}
		default:
			result[i] = val
		}
	}
	return result
}
