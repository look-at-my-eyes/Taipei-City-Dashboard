<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { ref, defineProps, watch } from "vue";
import { useDialogStore } from "../../store/dialogStore";
import { useContentStore } from "../../store/contentStore";
import CreateComponentInfo from "../../dashboardComponent/CreateComponentInfo.vue";
import DialogContainer from "./DialogContainer.vue";
import InputTags from "../utilities/forms/InputTags.vue";
import SelectButtons from "../utilities/forms/SelectButtons.vue";
import HistoryChart from "../charts/HistoryChart.vue";
import { chartsPerDataType } from "../../assets/configs/apexcharts/chartTypes";
import { timeTerms } from "../../assets/configs/AllTimes";
import { mapTypes } from "../../assets/configs/mapbox/mapConfig";
import http from "../../router/axios";
import generateSQLPrompt from "../../utils/generateSQLPrompt";

const dialogStore = useDialogStore();
const contentStore = useContentStore();

const props = defineProps(["searchParams"]);

const newComponent = ref({
	id: undefined,
	index: "",
	name: "",
	chart_config: {
		color: [],
		types: [],
		unit: "",
		categories: null,
	},
	chart_data: null,
	query_data: "",
	map_config: [],
	map_filter: null,
	history_config: {
		color: [],
		range: [],
	},
	history_data: null,
	query_type: "",
	source: "",
	time_from: "",
	time_to: "",
	update_freq: 0,
	update_freq_unit: "minute",
	short_desc: "",
	long_desc: "",
	use_case: "",
	links: [],
	contributors: [],
	city: "taipei",
});

const currentSettings = ref("all");
const tempInputStorage = ref({
	link: "",
	contributor: "",
	chartColor: "#000000",
	historyColor: "#000000",
});

const uploadedFiles = ref([]);
const generatedPrompt = ref("");

watch(currentSettings, async (val) => {
	if (val === "prompt") {
		generatedPrompt.value = await generateSQLPrompt(uploadedFiles.value, newComponent.value.query_type);
	}
});

async function handleConfirm() {
	try {
		const formData = new FormData();
		formData.append('component', JSON.stringify(newComponent.value));
		if (uploadedFiles.value && uploadedFiles.value.length > 0) {
			uploadedFiles.value.forEach((file, idx) => {
				formData.append('files', file);
			});
		}
		console.log(formData);
		await http.post(`/component/`, formData, {
			headers: {
				'Content-Type': 'multipart/form-data',
			},
		});
		dialogStore.showNotification("success", "組件新增成功");
		handleClose();
	} catch (error) {
		dialogStore.showNotification("fail", "組件新增失敗");
		console.error(error);
	}
}

function handleUpload(files) {
	uploadedFiles.value = files;
}

function handleClose() {
	currentSettings.value = "all";
	dialogStore.hideAllDialogs();
	// 重置 newComponent
	Object.assign(newComponent.value, {
		index: "",
		name: "",
		chart_config: {
			color: [],
			types: [],
			unit: "",
		},
		query_type: "",
		source: "",
		time_from: "",
		time_to: "",
		update_freq: 0,
		update_freq_unit: "minute",
		short_desc: "",
		long_desc: "",
		use_case: "",
		links: [],
		contributors: [],
		city: "taipei",
		query_chart: "",
		map_filter: "",
		map_config: [],
	});
}

function addMapConfig() {
	newComponent.value.map_config.push({
		id: undefined,
		index: "",
		title: "",
		type: "",
		size: null,
		icon: null,
		paint: null,
		property: null,
	});
}

function deleteMapConfig(index) {
	newComponent.value.map_config.splice(index, 1);
}
</script>

<template>
	<DialogContainer
		:dialog="`createComponent`"
		@on-close="handleClose"
	>
		<div class="createcomponent">
			<div class="createcomponent-header">
				<h2>組件設定</h2>
				<button @click="handleConfirm">
					確定新增
				</button>
			</div>
			<div class="createcomponent-tabs">
				<button
					:class="{ active: currentSettings === 'all' }"
					@click="currentSettings = 'all'"
				>
					整體
				</button>
				<button
					:class="{ active: currentSettings === 'chart' }"
					@click="currentSettings = 'chart'"
				>
					圖表
				</button>
				<button
					:class="{ active: currentSettings == 'map' }"
					@click="currentSettings = 'map'"
				>
					地圖
				</button>
				<button
					:class="{ active: currentSettings === 'prompt' }"
					@click="currentSettings = 'prompt'"
				>
					SQL
				</button>
				<!-- <button
					v-if="newComponent.history_config"
					:class="{ active: currentSettings === 'history' }"
					@click="currentSettings = 'history'"
				>
					歷史軸
				</button> -->
			</div>
			<div class="createcomponent-content">
				<div class="createcomponent-settings">
					<div
						v-if="currentSettings === 'all'"
						class="createcomponent-settings-items"
					>
						<label>組件名稱* ({{
							newComponent.name.length
						}}/10)</label>
						<input
							v-model="newComponent.name"
							type="text"
							:minlength="1"
							:maxlength="15"
							required
						>
						<div class="two-block">
							<label>城市</label>
							<label>組件 Index</label>
						</div>
						<div class="two-block">
							<select v-model="newComponent.city">
								<option value="taipei">台北</option>
								<option value="metrotaipei">雙北</option>
							</select>
							<input
								v-model="newComponent.index"
								type="text"
								:minlength="1"
								:maxlength="30"
								required
							>
						</div>
						<label>資料來源*</label>
						<input
							v-model="newComponent.source"
							type="text"
							:minlength="1"
							:maxlength="12"
							required
						>
						<label>更新頻率* (0 = 不定期更新)</label>
						<div class="two-block">
							<input
								v-model="newComponent.update_freq"
								type="number"
								:min="0"
								:max="31"
								required
							>
							<select v-model="newComponent.update_freq_unit">
								<option value="minute" />
								<option value="hour">
									時
								</option>
								<option value="day">
									天
								</option>
								<option value="week">
									週
								</option>
								<option value="month">
									月
								</option>
								<option value="year">
									年
								</option>
							</select>
						</div>
						<label>資料區間</label>
						<!-- eslint-disable no-mixed-spaces-and-tabs -->
						<div class="three-block">
							<select
								v-model="newComponent.time_from"
								@change="
									() => {
										if (
											[
												'current',
												'static',
												'demo',
												'maintain',
											].includes(
												newComponent.time_from
											)
										) {
											newComponent.time_to = '';
										} else {
											newComponent.time_to = 'now';
										}
									}
								"
							>
								<option
									v-for="time in [
										'current',
										'static',
										'demo',
										'maintain',
										'day_start',
										'week_start',
										'month_start',
										'quarter_start',
										'year_start',
										'day_ago',
										'week_ago',
										'month_ago',
										'quarter_ago',
										'halfyear_ago',
										'year_ago',
									]"
									:key="time"
									:value="time"
								>
									{{ timeTerms[time] }}
								</option>
							</select>
							<div
								:style="{
									display: 'flex',
									alignItems: 'center',
									justifyContent: 'center',
								}"
							>
								至
							</div>
							<input
								:value="
									newComponent.time_to === 'now'
										? '現在'
										: 'N/A'
								"
								:disabled="true"
							>
						</div>
						<label required>組件簡述* ({{
							newComponent.short_desc.length
						}}/50)</label>
						<textarea
							v-model="newComponent.short_desc"
							:minlength="1"
							:maxlength="50"
							required
						/>
						<label>組件詳述* ({{
							newComponent.long_desc.length
						}}/100)</label>
						<textarea
							v-model="newComponent.long_desc"
							:minlength="1"
							:maxlength="100"
							required
						/>
						<label>範例情境* ({{
							newComponent.use_case.length
						}}/100)</label>
						<textarea
							v-model="newComponent.use_case"
							:minlength="1"
							:maxlength="100"
							required
						/>
						<label>資料連結</label>
						<InputTags
							:tags="newComponent.links"
							@deletetag="
								(index) => {
									newComponent.links.splice(index, 1);
								}
							"
							@updatetagorder="
								(updatedTags) => {
									newComponent.links = updatedTags;
								}
							"
						/>
						<input
							v-model="tempInputStorage.link"
							type="text"
							:minlength="1"
							@keypress.enter="
								() => {
									if (tempInputStorage.link.length > 0) {
										newComponent.links.push(
											tempInputStorage.link
										);
										tempInputStorage.link = '';
									}
								}
							"
						>
						<label>貢獻者</label>
						<InputTags
							:tags="newComponent.contributors"
							@deletetag="
								(index) => {
									newComponent.contributors.splice(
										index,
										1
									);
								}
							"
							@updatetagorder="
								(updatedTags) => {
									newComponent.contributors = updatedTags;
								}
							"
						/>
						<input
							v-model="tempInputStorage.contributor"
							type="text"
							@keypress.enter="
								() => {
									if (
										tempInputStorage.contributor.length > 0
									) {
										newComponent.contributors.push(
											tempInputStorage.contributor
										);
										tempInputStorage.contributor = '';
									}
								}
							"
						>
					</div>
					<div
						v-else-if="currentSettings === 'chart'"
						class="createcomponent-settings-items"
					>
						<label>圖表資料型態</label>
						<select
							v-model="newComponent.query_type"
							@change="newComponent.chart_config.types = []"
						>
							<option value="two_d">
								二維資料
							</option>
							<option value="three_d">
								三維資料
							</option>
							<option value="time">
								時間序列資料
							</option>
							<option value="percent">
								百分比資料
							</option>
							<option value="map_legend">
								圖例資料
							</option>
						</select>
						<label>資料單位*</label>
						<input
							v-model="newComponent.chart_config.unit"
							type="text"
							:minlength="1"
							:maxlength="6"
							required
						>
						<label>圖表類型*（限3種，依點擊順序排列）</label>
						<SelectButtons
							:tags="
								chartsPerDataType[newComponent.query_type]
							"
							v-model:selected="newComponent.chart_config.types"
							:limit="3"
						/>
						<label>圖表顏色</label>
						<InputTags
							:tags="newComponent.chart_config.color"
							:color-data="true"
							@deletetag="
								(index) => {
									newComponent.chart_config.color.splice(
										index,
										1
									);
								}
							"
							@updatetagorder="
								(updatedTags) => {
									newComponent.chart_config.color =
										updatedTags;
								}
							"
						/>
						<input
							v-model="tempInputStorage.chartColor"
							type="color"
							class="createcomponent-settings-inputcolor"
							@focusout="
								() => {
									if (
										tempInputStorage.chartColor.length === 7
									) {
										newComponent.chart_config.color.push(
											tempInputStorage.chartColor
										);
										tempInputStorage.chartColor = '#000000';
									}
								}
							"
						>
					</div>
					<div
						v-else-if="currentSettings === 'history'"
						class="createcomponent-settings-items"
					>
						<label>歷史軸時間區間
							(依點擊順序排列，資料無法預覽)</label>
						<SelectButtons
							:tags="[
								'month_ago',
								'quarter_ago',
								'halfyear_ago',
								'year_ago',
								'twoyear_ago',
								'fiveyear_ago',
								'tenyear_ago',
							]"
							:selected="newComponent.history_config.range"
							:limit="5"
							@updatetagorder="
								(updatedTags) => {
									newComponent.history_config.range =
										updatedTags;
								}
							"
						/>
						<label>歷史軸顏色 (若無提供沿用圖表顏色)</label>
						<InputTags
							:tags="newComponent.history_config.color"
							:color-data="true"
							@deletetag="
								(index) => {
									newComponent.history_config.color.splice(
										index,
										1
									);
								}
							"
							@updatetagorder="
								(updatedTags) => {
									newComponent.history_config.color =
										updatedTags;
								}
							"
						/>
						<input
							v-model="tempInputStorage.historyColor"
							type="color"
							class="createcomponent-settings-inputcolor"
							@focusout="
								() => {
									if (
										tempInputStorage.historyColor.length ===
										7
									) {
										newComponent.history_config.color.push(
											tempInputStorage.historyColor
										);
										tempInputStorage.historyColor =
											'#000000';
									}
								}
							"
						>
					</div>
					<div v-else-if="currentSettings === 'map'">
						<div v-if="newComponent.map_config.length === 0" style="padding: 2rem; text-align: center;">
							<button @click="addMapConfig" style="padding: 8px 16px; border-radius: 5px; background: var(--color-highlight); color: white; font-size: 1rem; cursor: pointer;">新增地圖</button>
						</div>
						<div v-else>
							<div
								v-for="(map_config, index) in newComponent.map_config"
								:key="index"
								class="createcomponent-settings-items"
							>
								<hr v-if="index > 0">
								<div style="display: flex; justify-content: space-between; align-items: center;">
									<label>地圖{{ index + 1 }} Index / 名稱</label>
									<button @click="deleteMapConfig(index)" style="color: white; border: none; border-radius: 100%; width: 20px; height: 20px; display: flex; align-items: center; justify-content: center; padding: 0; cursor: pointer; font-size: 1rem; line-height: 1; padding-bottom: 2.5px;">
										&times;
									</button>
								</div>
								<label>地圖{{ index + 1 }} Index</label>
								<input
									v-model="newComponent.map_config[index].index"
									:maxlength="30"
									:minlength="1"
									placeholder="Index"
									required
								>
								<label>地圖{{ index + 1 }} 名稱* ({{ newComponent.map_config[index].title.length }}/10)</label>
								<input
									v-model="newComponent.map_config[index].title"
									type="text"
									:minlength="1"
									:maxlength="10"
									placeholder="名稱"
									required
								>
								<label>地圖{{ index + 1 }} 類型*</label>
								<select
									v-model="newComponent.map_config[index].type"
								>
									<option
										v-for="(value, key) in mapTypes"
										:key="key"
										:value="key"
									>
										{{ value }}
									</option>
								</select>
								<label>地圖{{ index + 1 }} 預設變形（大小/圖示）</label>
								<div class="two-block">
									<select
										v-model="newComponent.map_config[index].size"
									>
										<option :value="''">無</option>
										<option value="small">small (點圖)</option>
										<option value="big">big (點圖)</option>
										<option value="wide">wide (線圖)</option>
									</select>
									<select
										v-model="newComponent.map_config[index].icon"
									>
										<option :value="''">無</option>
										<option value="heatmap">heatmap (點圖)</option>
										<option value="dash">dash (線圖)</option>
										<option value="metro">metro (符號圖)</option>
										<option value="metro-density">metro-density (符號圖)</option>
										<option value="triangle_green">triangle_green (符號圖)</option>
										<option value="triangle_white">triangle_white (符號圖)</option>
										<option value="youbike">youbike (符號圖)</option>
										<option value="bus">bus (符號圖)</option>
										<option value="cctv">cctv (符號圖)</option>
									</select>
								</div>
								<label>地圖{{ index + 1 }} Paint屬性</label>
								<textarea
									v-model="newComponent.map_config[index].paint"
								/>
								<label>地圖{{ index + 1 }} Popup標籤</label>
								<textarea
									v-model="newComponent.map_config[index].property"
								/>
							</div>
							<div style="text-align: center; margin-top: 1rem;">
								<button @click="addMapConfig" style="padding: 2px 12px; border-radius: 5px; background: var(--color-highlight); color: white; font-size: 1rem; cursor: pointer; margin-bottom: 1rem;">新增地圖</button>
							</div>
						</div>
					</div>
					<div
						v-else-if="currentSettings === 'prompt'"
						class="createcomponent-settings-items"
					>
						<label>SQL 查詢語句</label>
						<textarea
							v-model="newComponent.query_chart"
							placeholder="請輸入 SQL 查詢語句..."
							style="min-height: 300px; font-family: monospace;"
						/>
						<p style="color: #888; font-size: 13px; margin-top: 4px;">
							請輸入對應資料來源的 SQL Query，將用於組件資料查詢。
						</p>
					</div>
				</div>
				<div class="createcomponent-preview">
					<CreateComponentInfo
						:key="`${newComponent.index}-${newComponent.chart_config.color}-${newComponent.chart_config.types}`"
						:config="JSON.parse(JSON.stringify(newComponent))"
						:active-city="newComponent.city"
						:city-tag="contentStore.cityManager.getTagList(newComponent.city)"
						:current-settings="currentSettings"
						:generated-prompt="generatedPrompt"
						mode="large"
						@upload="handleUpload"
					/>
					<div
						v-show="currentSettings === 'history'"
						:style="{ width: '300px' }"
					>
						<HistoryChart
							:key="`${newComponent.index}-${newComponent.history_config.color}`"
							:chart_config="newComponent.chart_config"
							:series="newComponent.history_data"
							:history_config="
								JSON.parse(
									JSON.stringify(
										newComponent.history_config
									)
								)
							"
						/>
					</div>
				</div>
			</div>
		</div>
	</DialogContainer>
</template>

<style scoped lang="scss">
.createcomponent {
	width: 750px;
	height: 500px;

	&-header {
		display: flex;
		justify-content: space-between;

		button {
			display: flex;
			align-items: center;
			justify-self: baseline;
			padding: 2px 4px;
			border-radius: 5px;
			background-color: var(--color-highlight);
			font-size: var(--font-ms);
		}
	}

	&-content {
		height: calc(100% - 70px);
		display: grid;
		grid-template-columns: 1fr 350px;
	}

	&-tabs {
		height: 30px;
		display: flex;
		align-items: center;
		margin-top: var(--font-s);

		button {
			width: 70px;
			height: 30px;
			border-radius: 5px 5px 0px 0px;
			background-color: var(--color-border);
			font-size: var(--font-m);
			color: var(--color-text);
			cursor: pointer;
			transition: background-color 0.2s;

			&:hover {
				background-color: var(--color-complement-text);
			}
		}
		.active {
			background-color: var(--color-complement-text);
		}
	}

	&-settings {
		padding: 0 0.5rem 0.5rem 0.5rem;
		margin-right: var(--font-ms);
		border-radius: 0px 5px 5px 5px;
		border: solid 1px var(--color-border);
		overflow-y: scroll;

		label {
			margin: 8px 0 4px;
			font-size: var(--font-s);
			color: var(--color-complement-text);
		}

		.two-block {
			display: grid;
			grid-template-columns: 1fr 1fr;
			column-gap: 0.4rem;
		}
		.three-block {
			display: grid;
			grid-template-columns: 1fr 2rem 1fr;
			column-gap: 0.5rem;
		}

		&-items {
			display: flex;
			flex-direction: column;

			hr {
				margin: var(--font-ms) 0 0.5rem;
				border: none;
				border-bottom: dashed 1px var(--color-complement-text);
			}
		}

		&-inputcolor {
			width: 140px;
			height: 40px;
			appearance: none;
			display: flex;
			justify-content: center;
			align-items: center;
			padding: 0;
			outline: none;
			cursor: pointer;

			&::-webkit-color-swatch {
				border: none;
				border-radius: 5px;
			}
			&::-moz-color-swatch {
				border: none;
			}
			&:before {
				content: "選擇顏色";
				position: absolute;
				display: block;
				border-radius: 5px;
				font-size: var(--font-ms);
				color: var(--color-complement-text);
			}
			&:focus:before {
				content: "點擊空白處確認";
				text-shadow: 0px 0px 1px black;
			}
		}

		&::-webkit-scrollbar {
			width: 4px;
		}
		&::-webkit-scrollbar-thumb {
			background-color: rgba(136, 135, 135, 0.5);
			border-radius: 4px;
		}
		&::-webkit-scrollbar-thumb:hover {
			background-color: rgba(136, 135, 135, 1);
		}
	}

	&-preview {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		border-radius: 5px;
		border: solid 1px var(--color-border);
	}
}
</style>
