import promptTemplate from './promptTemplate.txt?raw';
import { generatePgTableDef } from './generatePgTableDef';

const examples = {
	two_d: `type TwoDimensionalData struct {
    Xaxis string  \`gorm:"column:x_axis" json:"x"\`
    Data  float64 \`gorm:"column:data"   json:"y"\`
}`,
	three_d: `type ThreeDimensionalData struct {
    Xaxis string  \`gorm:"column:x_axis" json:"x"\`
    Icon  string  \`gorm:"column:icon" OPTIONAL json:"icon"\`
    Yaxis string  \`gorm:"column:y_axis" json:"y"\`
    Data  int     \`gorm:"column:data" json:"data"\`
}`,
	time: `type TimeSeriesData struct {
    Xaxis time.Time \`gorm:"column:x_axis" json:"x"\`
    Yaxis string    \`gorm:"column:y_axis" json:"y"\`
    Data  float64   \`gorm:"column:data" json:"data"\`
}`,
	percent: `type ThreeDimensionalData struct {
    Xaxis string  \`gorm:"column:x_axis" json:"x"\`
    Icon  string  \`gorm:"column:icon" OPTIONAL json:"icon"\`
    Yaxis string  \`gorm:"column:y_axis" json:"y"\`
    Data  int     \`gorm:"column:data" json:"data"\`
}`,
	map_legend: `type MapLegendData struct {
    Name  string  \`gorm:"column:name" json:"name"\`
    Type  string  \`gorm:"column:type" json:"type"\`
    Icon  string  \`gorm:"column:icon" json:"icon" OPTIONAL\`
    Value float64 \`gorm:"column:value" json:"value"\`
}`
};


/**
 * @param {File[]} files
 * @param {string} queryType
 */
async function generateSQLPrompt(files, queryType) {
	const example = examples[queryType] || '';
	const createTableQueries = await Promise.all(files.map(file => generatePgTableDef(file, "public", file.name.split('.')[0])));
	const createTableQuery = createTableQueries.join('\n---------------------------------------------\n');

	const prompt = promptTemplate
		.replace('{{CREATE_TABLE_QUERY}}', `\n${createTableQuery}\n`)
		.replace('{{QUERY_TYPE}}', `${queryType}`)
		.replace('{{QUERY_TYPE_EXAMPLE}}', `${example}`);

	console.log(prompt);

	return prompt;
}

export default generateSQLPrompt;