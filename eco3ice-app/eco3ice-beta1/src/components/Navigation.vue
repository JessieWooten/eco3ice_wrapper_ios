<template lang="html">
  <div>
    <f7-navbar>
      <f7-nav-left>
        <div class="panel-launcher" @click="togglePanel">
          <i class="f7-icons e3i-gray-light" style="margin-left: 10px; font-weight: 600;">bars</i>
        </div>
      </f7-nav-left>
      <f7-nav-center sliding="" class="e3i-blue nav-title" v-html="$t('Eco3Ice Metrics')"></f7-nav-center>
      <f7-nav-right></f7-nav-right>
    </f7-navbar>
  </div>
</template>

<script>
export default {
  methods: {
    togglePanel: function() {
      this.$emit('togglePanel');
    }
  }
}
</script>
