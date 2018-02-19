<template lang="html">
  <div>
    <!--if local log is displayed -->
    <div v-if="isLocalLog">
      <div v-if="localLogIsEmpty" class="flex" >
        <div>
          <p class="e3i-gray-light">{{$t("loading...")}}</p>
          <div class="flex">
            <div class="preloader preloader-gray" style="width: 25px; height: 25px;"></div>
          </div>
        </div>
      </div>
      <f7-list v-else>
        <div class="log-data" v-for="(line,index) in localLogData">
            <span class="log-index">{{index + 1}}</span>
            <span>{{line}}</span>
        </div>
      </f7-list>
    </div>
    <!--if current log is displayed -->
    <div v-else>
      <div v-if="logIsEmpty" class="flex" >
        <div>
          <p class="e3i-gray-light">{{$t("loading...")}}</p>
          <div class="flex">
            <div class="preloader preloader-gray" style="width: 25px; height: 25px;"></div>
          </div>
        </div>
      </div>
      <f7-list v-else>
        <div class="log-data" v-for="(line,index) in log">
            <span class="log-index">{{index + 1}}</span>
            <span>{{line}}</span>
        </div>
      </f7-list>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    isLogOpened: Boolean,
    log: Array,
    isLocalLog: Boolean,
    localLogData: Array,
    logIsEmpty: Boolean,
    localLogIsEmpty: Boolean
  },
  computed:{
  },
  methods: {
  },
  data: function() {
    return {
      displayName: ""
    }
  }
}
</script>
