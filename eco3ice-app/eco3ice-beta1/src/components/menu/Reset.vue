<template lang="html">
  <div @actions:closed="closeResetPrompt()">
    <f7-actions id="reset" animated="true" :opened="isResetOpened">
      <f7-actions-group>
        <f7-actions-label class="reset-title separator">{{$t("Are you sure you want to reset")}}<br/> {{ unitName }}?</f7-actions-label>
        <f7-actions-button @click="closeResetPrompt" class="e3i-gray-light e3i-reset-button" style="border-right: 1px solid #c2c2c2;">{{$t("Cancel")}}</f7-actions-button
        ><f7-actions-button @click="reset" class="e3i-fail e3i-reset-button">{{$t("Reset")}}</f7-actions-button>
      </f7-actions-group>
    </f7-actions>
  </div>
</template>

<script>
import { promptBus } from '../../main'
export default {
  props: {
    isResetOpened: Boolean,
    unitName: String
  },
  computed:{
  },
  methods: {
    closeResetPrompt: function(){
      this.$emit('resetClosed');
    },
    reset: function() {
      this.$emit('resetUnit');
      this.closeResetPrompt();
      this.$emit('closeAll');
    },
    data: function() {
      return {
        true: true
      }
    }
  }
}
</script>
