import dayjs from "dayjs";
import timezone from "dayjs/plugin/timezone";

dayjs.extend(timezone);

/**
 * @param {File} file
 * @param {string} schemaName
 * @param {string} tableName
 */
export async function generatePgTableDef(file, schemaName, tableName) {
	const text = await file.text();
	const data = parseCSV(text);

	const header = data[0];
	// sample at most 100 rows
	const sampleRows = data.slice(1, 101);

	const inferredTypes = inferColumnTypes(header, sampleRows);

	// Build and execute CREATE TABLE
	const columnDefs = ['"id" SERIAL PRIMARY KEY'];
	for (const i in header) {
		const col = header[i];
		const columnDef = `"${col}" ${inferredTypes[i]}`;
		columnDefs.push(columnDef);
	}
	return `CREATE TABLE "${schemaName}"."${tableName}" (${columnDefs.join(", ")});`;
}

/**
 * @param {string} str
 */
function parseCSV(str) {
	/** @type {string[][]} */
	const arr = [];
	let inQuote = false;

	for (let row = 0, col = 0, c = 0; c < str.length; c++) {
		const curr = str[c];
		const next = str[c + 1];
		arr[row] = arr[row] ?? [];
		arr[row][col] = arr[row][col] ?? "";

		if (curr == '"' && inQuote && next == '"') {
			arr[row][col] += curr;
			++c;
			continue;
		}

		if (curr == '"') {
			inQuote = !inQuote;
			continue;
		}

		if (curr == "," && !inQuote) {
			++col;
			continue;
		}

		if (curr == "\r" && next == "\n" && !inQuote) {
			++row;
			col = 0;
			++c;
			continue;
		}

		if (curr == "\n" && !inQuote) {
			++row;
			col = 0;
			continue;
		}
		if (curr == "\r" && !inQuote) {
			++row;
			col = 0;
			continue;
		}

		arr[row][col] += curr;
	}
	return arr;
}

const TYPE_PRIORITY = Object.freeze({
	INTEGER: 1,
	NUMERIC: 2,
	"DOUBLE PRECISION": 2,
	"TIMESTAMP WITH TIME ZONE": 3,
	"TIMESTAMP WITHOUT TIME ZONE": 4,
	TEXT: 5,
});

/**
 * @param {string[]} header
 * @param {string[][]} sampleRows
 */
function inferColumnTypes(header, sampleRows) {
	const result = Array.from({ length: header.length }, () => "");
	for (const i in header) {
		let bestPriority = 0;
		let bestType = "TEXT";
		for (const row of sampleRows) {
			if (i >= row.length) {
				continue;
			}
			const t = inferPgType(row[i].trim());
			if (TYPE_PRIORITY[t] > bestPriority) {
				bestPriority = TYPE_PRIORITY[t];
				bestType = t;
			}
		}
		result[i] = bestType;
	}
	return result;
}

/**
 * @param {string} valueStr
 * @returns {"INTEGER" | "NUMERIC" | "TIMESTAMP WITH TIME ZONE" | "TIMESTAMP WITHOUT TIME ZONE" | "TEXT"}
 */
function inferPgType(valueStr) {
	const parsed = Number(valueStr);
	if (!isNaN(parsed) && Number.isInteger(parsed)) {
		return "INTEGER";
	} else if (!isNaN(parsed)) {
		return "NUMERIC";
	} else if (dayjs(valueStr).isValid()) {
		return hasTimeZone(valueStr)
			? "TIMESTAMP WITH TIME ZONE"
			: "TIMESTAMP WITHOUT TIME ZONE";
	}
	return "TEXT";
}

/**
 * @param {string} valueStr
 */
function hasTimeZone(valueStr) {
	// Matches:
	// - Z or z for UTC
	// - +HH:mm or -HH:mm for offsets
	return /[Zz]|[+-]\d{2}:\d{2}$/.test(valueStr);
}
