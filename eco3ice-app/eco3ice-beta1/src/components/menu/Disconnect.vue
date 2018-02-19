<template lang="html">
  <div @actions:closed="closeDisconnectPrompt()">
    <f7-actions id="disconnect" animated="true" :opened="isDisconnectOpened">
      <f7-actions-group>
        <f7-actions-label class="reset-title separator">{{$t("Are you sure you want to disconnect")}}<br/> {{ unitName }}?</f7-actions-label>
        <f7-actions-button @click="closeDisconnectPrompt" class="e3i-gray-light e3i-reset-button" style="border-right: 1px solid #c2c2c2;">{{$t("Cancel")}}</f7-actions-button
        ><f7-actions-button @click="disconnect" class="e3i-fail e3i-reset-button">{{$t("Disconnect")}}</f7-actions-button>
      </f7-actions-group>
    </f7-actions>
  </div>
</template>

<script>
import { promptBus } from '../../main'
export default {
  props: {
    isDisconnectOpened: Boolean,
    unitName: String
  },
  computed:{
  },
  methods: {
    closeDisconnectPrompt: function(){
      this.$emit('disconnectClosed');
    },
    disconnect: function() {
      this.$emit('disconnectUnit');
      this.closeDisconnectPrompt();
    },
    data: function() {
      return {
        true: true
      }
    }
  }
}
</script>
