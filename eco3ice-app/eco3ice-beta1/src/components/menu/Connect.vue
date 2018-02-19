<template lang="html">
  <div @actions:closed="closeConnectPrompt()">
    <f7-actions :opened="isConnectOpened">
      <f7-actions-group>
        <f7-actions-label class="reset-title">{{$t("Select Unit")}}</f7-actions-label>
        <f7-list class="unit-list">
          <div v-if="unitList.length <= 0" class="searching-container">
            <p class="e3i-gray">{{$t("searching for nearby units")}}</p>
            <div class="progress-bar-container">
              <f7-progressbar infinite color="blue" ></f7-progressbar>
            </div>
          </div>
          <f7-list-item
            v-else
            v-for="(unit, index) in unitList"
            :title="unit.name"
            class="menu-item"
            @click="selectUnit(unit.name, index)"
          >
            <img v-if="selectedUnitIndex === index" src="static/images/selected.png" class="selected-unit-icon" alt="°">
          </f7-list-item>
        </f7-list>
        <f7-actions-button @click="closeConnectPrompt" class="e3i-gray-light" style="width: 100% !important;">{{$t("Cancel")}}</f7-actions-button>
      </f7-actions-group>
    </f7-actions>
  </div>
</template>

<script>
export default {
  props:{
    isConnectOpened: Boolean,
    unitList: Array,
    selectedUnitIndex: Number
  },
  methods: {
    closeConnectPrompt: function() {
      this.$emit('connectPromptClosed');
    },
    selectUnit: function(unit, index) {
      console.log( unit + ' Selected' );
      this.$emit('unitSelected', index);
      this.closeConnectPrompt();
    }
  }
}
</script>
