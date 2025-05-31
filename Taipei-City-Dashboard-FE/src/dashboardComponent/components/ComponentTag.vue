<!-- Developed by Taipei Urban Intelligence Center 2023-2024-->

<!-- This component has two modes "outline" and "fill" which is controlled via the prop "mode" -->

<script setup>
defineProps({
	icon: String,
	text: String,
	mode: {
		type: String,
		default: "outline",
	},
	color: {
		type: String,
		default: "var(--color-complement-text)",
	},
});
</script>

<template>
  <div
    :class="{
      componenttag: true,
      'componenttag-fill': mode === 'fill',
      'componenttag-small': mode === 'small',
    }"
    :style="{
      borderColor: mode === 'fill' ? color : color,
      backgroundColor: mode === 'fill' ? color : 'transparent',
    }"
  >
    <span v-if="icon" :style="{ color: mode === 'fill' ? 'white' : color }">{{ icon }}</span>
    <p :style="{ color: mode === 'fill' ? 'white' : color }">{{ text }}</p>
  </div>
</template>

<style scoped lang="scss">
.componenttag {
	min-height: 1.5rem;
	max-height: 1.5rem;
	width: fit-content;
	max-width: 88px;
	display: flex;
	align-items: center;
	margin-right: 4px;
	padding: 0 4px;
	border: solid 1px;
	border-radius: 5px;
	overflow-x: hidden;
	user-select: none;

	span {
		margin-right: 4px;
		font-family: var(--font-icon);
	}

	p {
		max-height: var(--font-ms);
		font-size: var(--font-s);
	}

	&-fill {
		span,
		p {
			color: white;
		}
	}

	&-small {
		min-height: var(--font-ms);
		max-height: var(--font-ms);
		padding: 0 2px;
		margin-left: 8px;

		p {
			font-weight: 400;
		}

		&.city-tag-item {
			margin: 0;

			p {
				color: white;
			}

			&.taipei {
				background-color: var(--color-taipei);
			}
			&.metrotaipei {
				background-color: var(--color-metrotaipei);
			}
		}
	}
}
</style>
