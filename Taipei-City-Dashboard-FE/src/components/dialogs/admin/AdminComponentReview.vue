<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<script setup>
import { storeToRefs } from "pinia";
import { useAdminStore } from "../../../store/adminStore";
import { useDialogStore } from "../../../store/dialogStore";
import DialogContainer from "../DialogContainer.vue";

const dialogStore = useDialogStore();
const adminStore = useAdminStore();
const props = defineProps(["searchParams"]);

const { currentComponent } = storeToRefs(adminStore);

async function handleApproved() {
	currentComponent.value.status = "approved";
	await adminStore.updateComponent(props.searchParams);
	await adminStore.getSubmittedComponents(props.searchParams);
	handleClose();
}

async function handleRejected() {
	currentComponent.value.status = "rejected";
	await adminStore.updateComponent(props.searchParams);
	await adminStore.getSubmittedComponents(props.searchParams);
	handleClose();
}

function handleClose() {
	dialogStore.hideAllDialogs();
}
</script>

<template>
	<DialogContainer
		:dialog="`adminComponentReview`"
		@on-close="handleClose"
	>
		<div class="admincomponentreview">
			<div class="admincomponentreview-header">
				<h2>審查組件</h2>
				<div class="admincomponentreview-buttons">
					<button class="confirm-button" @click="handleApproved">
						<span class="material-icons">check</span>
					</button>
					<button class="cancel-button" @click="handleRejected" style="background-color: #ff0000;">
						<span class="material-icons">close</span>
					</button>
				</div>
			</div>
			<div class="admincomponentreview-content">
				<div class="admincomponentreview-content-item">
					<div class="info-section">
						<div class="info-header">
							<span class="material-icons">info</span>
							<h3>{{ currentComponent.name }}</h3>
						</div>
						<div class="info-content">
							<div class="info-row">
								<span class="label">組件名稱：</span>
								<span class="value">{{ currentComponent.name }}</span>
							</div>
							<div class="info-row">
								<span class="label">簡短描述：</span>
								<span class="value">{{ currentComponent.short_desc }}</span>
							</div>
							<div class="info-row">
								<span class="label">詳細描述：</span>
								<span class="value description">{{ currentComponent.long_desc }}</span>
							</div>
							<div class="info-row">
								<span class="label">使用案例：</span>
								<span class="value description">{{ currentComponent.use_case }}</span>
							</div>
							<div class="info-row">
								<span class="label">資料來源：</span>
								<span class="value">{{ currentComponent.source }}</span>
							</div>
							<div class="info-row">
								<span class="label">查詢類型：</span>
								<span class="value">{{ currentComponent.query_type }}</span>
							</div>
							<div class="info-row">
								<span class="label">圖表類型：</span>
								<span class="value">{{ currentComponent.chart_config.types.join(', ') }}</span>
							</div>
							<div class="info-row">
								<span class="label">資料單位：</span>
								<span class="value">{{ currentComponent.chart_config.unit }}</span>
							</div>
							<div class="info-row">
								<span class="label">資料類別：</span>
								<span class="value">{{ currentComponent.chart_config.categories?.join(', ') }}</span>
							</div>
							<div class="info-row">
								<span class="label">貢獻者：</span>
								<span class="value">{{ currentComponent.contributors?.join(', ') }}</span>
							</div>
							<div class="info-row">
								<span class="label">更新時間：</span>
								<span class="value">{{ new Date(currentComponent.updated_at).toLocaleString('zh-TW') }}</span>
							</div>
							<div class="info-row" v-if="currentComponent.links?.length">
								<span class="label">相關連結：</span>
								<div class="value links">
									<a v-for="(link, index) in currentComponent.links" 
										:key="index" 
										:href="link" 
										target="_blank"
										class="link-item">
										{{ link }}
									</a>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</DialogContainer>
</template>

<style scoped lang="scss">
.admincomponentreview {
	width: 600px;
	height: 350px;
	display: flex;
	flex-direction: column;

	@media (max-width: 600px) {
		display: none;
	}
	@media (max-height: 350px) {
		display: none;
	}

	&-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: var(--font-ms);
		padding: 0 var(--font-ms);
		flex-shrink: 0;

		h2 {
			font-size: var(--font-l);
		}
	}

	&-buttons {
		display: flex;
		gap: 8px;

		button {
			width: 36px;
			height: 36px;
			display: flex;
			align-items: center;
			justify-content: center;
			border-radius: 50%;
			border: none;
			cursor: pointer;
			transition: background-color 0.2s;

			.material-icons {
				font-size: 20px;
			}

			&.confirm-button {
				background-color: var(--color-highlight);
				color: white;

				&:hover {
					filter: brightness(0.9);
				}
			}

			&.cancel-button {
				background-color: #f5f5f5;
				color: #666;

				&:hover {
					background-color: #e0e0e0;
				}
			}
		}
	}

	&-content {
		flex: 1;
		overflow-y: auto;
		padding: 0 var(--font-ms);
		margin-bottom: var(--font-ms);

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

		&-item {
			.info-section {
				background-color: var(--color-background);
				border-radius: 8px;
				padding: 16px;
				box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);

				.info-header {
					display: flex;
					align-items: center;
					gap: 8px;
					margin-bottom: 12px;
					padding-bottom: 8px;
					border-bottom: 1px solid var(--color-border);

					.material-icons {
						color: var(--color-highlight);
						font-size: 20px;
					}

					h3 {
						margin: 0;
						font-size: var(--font-m);
						color: var(--color-text);
					}
				}

				.info-content {
					p {
						margin: 0;
						line-height: 1.6;
						color: var(--color-text-secondary);
					}

					.info-row {
						display: flex;
						align-items: flex-start;
						margin-top: 12px;
						padding: 8px 0;
						border-bottom: 1px dashed var(--color-border);

						&:last-child {
							border-bottom: none;
						}

						.label {
							font-weight: 500;
							color: var(--color-text);
							min-width: 100px;
							padding-right: 12px;
						}

						.value {
							color: var(--color-text-secondary);
							flex: 1;
							line-height: 1.6;

							&.description {
								white-space: pre-line;
							}

							&.links {
								display: flex;
								flex-direction: column;
								gap: 4px;

								.link-item {
									color: var(--color-highlight);
									text-decoration: none;
									word-break: break-all;

									&:hover {
										text-decoration: underline;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
</style>
