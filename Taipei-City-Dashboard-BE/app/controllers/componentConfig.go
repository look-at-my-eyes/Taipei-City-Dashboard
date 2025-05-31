// Package controllers stores all the controllers for the Gin router.
package controllers

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"TaipeiCityDashboardBE/app/models"
	"TaipeiCityDashboardBE/internal"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

/*
GetAllComponents retrieves all public components from the database.
GET /api/v1/component

| Param         | Description                                         | Value                        | Default |
| ------------- | --------------------------------------------------- | ---------------------------- | ------- |
| pagesize      | Number of components per page.                      | `int`                        | -       |
| pagenum       | Page number. Only works if pagesize is defined.     | `int`                        | 1       |
| searchbyname  | Text string to search name by.                      | `string`                     | -       |
| searchbyindex | Text string to search index by.                     | `string`                     | -       |
| filterby      | Column to filter by. `filtervalue` must be defined. | `string`                     | -       |
| filtermode    | How the data should be filtered.                    | `eq`, `ne`, `gt`, `lt`, `in` | `eq`    |
| filtervalue   | The value to filter by.                             | `int`, `string`              | -       |
| sort          | The column to sort by.                              | `string`                     | -       |
| order         | Ascending or descending.                            | `asc`, `desc`                | `asc`   |
*/

type componentQuery struct {
	City          string `form:"city"`
	PageSize      int    `form:"pagesize"`
	PageNum       int    `form:"pagenum"`
	Sort          string `form:"sort"`
	Order         string `form:"order"`
	FilterBy      string `form:"filterby"`
	FilterMode    string `form:"filtermode"`
	FilterValue   string `form:"filtervalue"`
	SearchByIndex string `form:"searchbyindex"`
	SearchByName  string `form:"searchbyname"`
}

// FIXME:
// 這邊的 component 是半成品，無法直接使用
// 缺少 components.index(component_charts.index)，後續需要設計流程補上
func CreateComponent(c *gin.Context) {
	var component models.Component
	var queryChart models.QueryCharts
	var cityComponent models.CityComponent

	// 1. Bind the request body to the component and make sure it's valid
	err := c.ShouldBindJSON(&component)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 2. Create the component
	cityComponent, err = models.CreateComponent(component.Index, component.Name, queryChart.City, queryChart.HistoryConfig, queryChart.MapFilter, queryChart.TimeFrom, queryChart.TimeTo, queryChart.UpdateFreq, queryChart.UpdateFreqUnit, queryChart.Source, queryChart.ShortDesc, queryChart.LongDesc, queryChart.UseCase, queryChart.Links, queryChart.Contributors)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 3. Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": cityComponent})
}

func GetAllComponents(c *gin.Context) {
	// Get all query parameters from context
	var query componentQuery
	c.ShouldBindQuery(&query)

	if !(query.City == "taipei" || query.City == "metrotaipei" || query.City == "") {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid City Name"})
		return
	}

	cityComponents, totalComponents, resultNum, err := models.GetAllComponents(query.City, query.PageSize, query.PageNum, query.Sort, query.Order, query.FilterBy, query.FilterMode, query.FilterValue, query.SearchByIndex, query.SearchByName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// Return the components
	c.JSON(http.StatusOK, gin.H{"status": "success", "total": totalComponents, "results": resultNum, "data": cityComponents})
}

/*
GetComponentByID retrieves a public component from the database by ID.
GET /api/v1/component/:id
*/
func GetComponentByID(c *gin.Context) {
	// Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 1.1 Get the city name from the URL
	var query componentQuery
	c.ShouldBindQuery(&query)
	if !(query.City == "taipei" || query.City == "metrotaipei" || query.City == "") {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid City Name"})
		return
	}

	if query.City == "" {
		query.City = "taipei"
	}

	// Find the component
	cityComponent, err := models.GetComponentByID(id, query.City)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": cityComponent})
}

/*
GetComponentByIDAll retrieves public components from the database by ID.
GET /api/v1/component/:id/all
*/
func GetComponentByIDAll(c *gin.Context) {
	// Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// Find the component
	cityComponent, err := models.GetComponentByIDAll(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": cityComponent})
}

type createComponentFormData struct {
	Index          string       `json:"index"`
	Name           string       `json:"name"`
	ChartConfig    ChartConfig  `json:"chart_config"`
	QueryType      string       `json:"query_type"`
	QueryChart     string       `json:"query_chart"`
	MapConfig      []*MapConfig `json:"map_config"`
	MapFilter      string       `json:"map_filter"`
	Source         string       `json:"source"`
	TimeFrom       string       `json:"time_from"`
	TimeTo         string       `json:"time_to"`
	UpdateFreq     int          `json:"update_freq"`
	UpdateFreqUnit string       `json:"update_freq_unit"`
	ShortDesc      string       `json:"short_desc"`
	LongDesc       string       `json:"long_desc"`
	UseCase        string       `json:"use_case"`
	Links          []string     `json:"links"`
	Contributors   []string     `json:"contributors"`
	City           string       `json:"city"`
}

type ChartConfig struct {
	Color []string `json:"color"`
	Types []string `json:"types"`
	Unit  string   `json:"unit"`
}

type MapConfig struct {
	Index    string  `json:"index"`
	Paint    *string `json:"paint"`
	Property *string `json:"property"`
	Title    string  `json:"title"`
	Type     string  `json:"type"`
	Size     *string `json:"size"`
	Icon     *string `json:"icon"`
	Source   string  `json:"source"`
	City     string  `json:"city"`
}

// CreateComponentWithForm creates a component in the database and updates component_charts, components, and query_charts tables.
func CreateComponentWithForm(c *gin.Context) {
	component := c.PostForm("component")
	var data createComponentFormData
	err := json.Unmarshal([]byte(component), &data)
	if err != nil {
		c.JSON(
			http.StatusBadRequest,
			gin.H{"status": "error", "message": fmt.Sprintf("Invalid JSON content: %s", err.Error())},
		)
		return
	}

	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(
			http.StatusBadRequest,
			gin.H{"status": "error", "message": "Invalid form data"},
		)
		return
	}

	tx := models.DBDashboard.Begin()
	defer tx.Rollback()

	files := form.File["files"]
	for _, fh := range files {
		file, err := fh.Open()
		if err != nil {
			log.Printf("warning: failed to open file '%s': %v\n", fh.Filename, err)
			continue
		}

		reader := csv.NewReader(file)
		csvdata, err := reader.ReadAll()
		if err != nil {
			log.Printf("warning: failed to read CSV: %v\n", err)
			continue
		}

		tableName := strings.TrimSuffix(filepath.Base(fh.Filename), filepath.Ext(fh.Filename))
		err = internal.PGImport(tx, csvdata, tableName, "public")
		if err != nil {
			c.JSON(
				http.StatusInternalServerError,
				gin.H{"status": "error", "message": "failed to import file into database"},
			)
			return
		}
	}

	tx2 := tx.Exec(data.QueryChart)
	if tx2.Error != nil {
		c.JSON(
			http.StatusBadRequest,
			gin.H{"status": "error", "message": "failed to execute query chart"},
		)
		return
	}

	// if checks passed, create records
	managerTx := models.DBManager.Begin()
	defer managerTx.Rollback()

	newMaps := []*models.ComponentMap{}
	for _, mapConfig := range data.MapConfig {
		newMaps = append(newMaps, mapConfigToModelComponentMap(mapConfig))
	}
	tx2 = managerTx.Create(newMaps)
	if tx2.Error != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{"status": "error", "message": "failed to create component maps"},
		)
		return
	}

	newComponentChart := models.ComponentChart{
		Index: data.Index,
		Color: pq.StringArray(data.ChartConfig.Color),
		Types: pq.StringArray(data.ChartConfig.Types),
		Unit:  data.ChartConfig.Unit,
	}
	tx2 = managerTx.Create(&newComponentChart)
	if tx2.Error != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{"status": "error", "message": "failed to create component chart"},
		)
		return
	}

	mapConfigIDs := []int64{}
	for _, componentMap := range newMaps {
		mapConfigIDs = append(mapConfigIDs, componentMap.ID)
	}

	freq := int64(data.UpdateFreq)
	newQueryChart := models.QueryCharts{
		Index:          data.Index,
		TimeFrom:       data.TimeFrom,
		TimeTo:         &data.TimeTo,
		UpdateFreq:     &freq,
		UpdateFreqUnit: data.UpdateFreqUnit,
		MapConfigIDs:   mapConfigIDs,
		MapFilter:      []byte(data.MapFilter),
		Source:         data.Source,
		ShortDesc:      data.ShortDesc,
		LongDesc:       data.LongDesc,
		UseCase:        data.UseCase,
		Links:          data.Links,
		Contributors:   data.Contributors,
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
		QueryType:      data.QueryType,
		QueryChart:     data.QueryChart,
		City:           data.City,
	}
	newComponent := models.Component{
		Index: data.Index,
		Name:  data.Name,
	}
	tx2 = managerTx.Create(&newComponent)
	if tx2.Error != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{"status": "error", "message": "failed to create component"},
		)
		return
	}

	tx2 = managerTx.Create(&newQueryChart)
	if tx2.Error != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{"status": "error", "message": "failed to create query chart"},
		)
		return
	}

	tx.Commit()
	managerTx.Commit()
}

func mapConfigToModelComponentMap(mapConfig *MapConfig) *models.ComponentMap {
	return &models.ComponentMap{
		Index:    mapConfig.Index,
		Title:    mapConfig.Title,
		Type:     mapConfig.Type,
		Source:   mapConfig.Source,
		Size:     mapConfig.Size,
		Icon:     mapConfig.Icon,
		Paint:    strPtrToJsonRawMessagePtr(mapConfig.Paint),
		Property: strPtrToJsonRawMessagePtr(mapConfig.Property),
	}
}

func strPtrToJsonRawMessagePtr(strPtr *string) *json.RawMessage {
	if strPtr == nil {
		return nil
	}
	str := *strPtr
	rawMsg := json.RawMessage(str)
	return &rawMsg
}

/*
UpdateComponent updates a component's config in the database.
PATCH /api/v1/component/:id
*/
func UpdateComponent(c *gin.Context) {
	var cityComponent models.CityComponent

	// 1. Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 1.1 Get the city name from the URL
	var query componentQuery
	c.ShouldBindQuery(&query)
	if !(query.City == "taipei" || query.City == "metrotaipei" || query.City == "") {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid City Name"})
		return
	}

	if query.City == "" {
		query.City = "taipei"
	}

	// 2. Check if the component exists
	_, err = models.GetComponentByID(id, query.City)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// 3. Bind the request body to the component and make sure it's valid
	err = c.ShouldBindJSON(&cityComponent)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 4. Update the component
	cityComponent, err = models.UpdateComponent(id, query.City, cityComponent.Name, cityComponent.HistoryConfig, cityComponent.MapFilter, cityComponent.TimeFrom, cityComponent.TimeTo, cityComponent.UpdateFreq, cityComponent.UpdateFreqUnit, cityComponent.Source, cityComponent.ShortDesc, cityComponent.LongDesc, cityComponent.UseCase, cityComponent.Links, cityComponent.Contributors)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 5. Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": cityComponent})
}

/*
UpdateComponentChartConfig updates a component's chart config in the database.
PATCH /api/v1/component/:id/chart
*/
func UpdateComponentChartConfig(c *gin.Context) {
	var chartConfig models.ComponentChart

	// 1. Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 1.1 Get the city name from the URL
	city := c.Query("city")
	if !(city == "taipei" || city == "metrotaipei" || city == "") {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid City Name"})
		return
	}

	if city == "" {
		city = "taipei"
	}

	// 2. Find the component and chart config
	component, err := models.GetComponentByID(id, city)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// 3. Bind the request body to the component and make sure it's valid
	err = c.ShouldBindJSON(&chartConfig)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 4. Update the chart config. Then update the update_time in components table.
	chartConfig, err = models.UpdateComponentChartConfig(component.Index, chartConfig.Color, chartConfig.Types, chartConfig.Unit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 5. Return the component
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": chartConfig})
}

/*
UpdateComponentMapConfig updates a component's map config in the database.
PATCH /api/v1/component/:id/map
*/
func UpdateComponentMapConfig(c *gin.Context) {
	var mapConfig models.ComponentMap

	// 1. Get the map config index from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid map config ID"})
		return
	}

	// 2. Bind the request body to the component and make sure it's valid
	err = c.ShouldBindJSON(&mapConfig)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 3. Update the map config
	mapConfig, err = models.UpdateComponentMapConfig(id, mapConfig.Index, mapConfig.Title, mapConfig.Type, mapConfig.Source, mapConfig.Size, mapConfig.Icon, mapConfig.Paint, mapConfig.Property)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	// 4. Return the map config
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": mapConfig})
}

/*
DeleteComponent deletes a component from the database.
DELETE /api/v1/component/:id

Note: Associated chart config will also be deleted. Associated map config will only be deleted if no other components are using it.
*/
func DeleteComponent(c *gin.Context) {
	var component models.CityComponent
	var queryChart models.QueryCharts

	// 1. Get the component ID from the context
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid component ID"})
		return
	}

	// 1.1 Get the city name from the URL
	city := c.Param("city")
	if !(city == "taipei" || city == "metrotaipei" || city == "") {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Invalid City Name"})
		return
	}

	if city == "" {
		city = "taipei"
	}

	// 2. Find the component
	component, err = models.GetComponentByID(id, city)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "component not found"})
		return
	}

	// 3. Delete the component
	deleteChartStatus, deleteMapStatus, err := models.DeleteComponent(id, component.Index, queryChart.MapConfigIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "chart_deleted": deleteChartStatus, "map_deleted": deleteMapStatus})
}
