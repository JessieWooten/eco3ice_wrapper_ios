<template lang="html">
  <div @actions:closed="closeDeletePrompt()">
    <f7-actions id="deleteLog" animated="true" :opened="deleteOpened">
      <f7-actions-group>
        <f7-actions-label class="reset-title separator">{{$t("Are you sure you want to Delete")}}<br/> {{ displayName }}?</f7-actions-label>
        <f7-actions-button @click="closeDeletePrompt" class="e3i-gray-light e3i-reset-button" style="border-right: 1px solid #c2c2c2;">{{$t("Cancel")}}</f7-actions-button
        ><f7-actions-button @click="deleteLog" class="e3i-fail e3i-reset-button">{{$t("Delete")}}</f7-actions-button>
      </f7-actions-group>
    </f7-actions>
  </div>
</template>

<script>
import { promptBus } from '../../main'
export default {
  props: {
    unitName: String,
    displayName: String,
    deleteOpened: Boolean
  },
  computed:{
  },
  methods: {
    closeDeletePrompt: function(){
      this.$emit('deleteClosed');
    },
    deleteLog: function() {
      this.$emit('deleteLog');
      this.closeDeletePrompt();
      this.$emit('close');
    },
    data: function() {
      return {
      }
    }
  }
}
</script>
