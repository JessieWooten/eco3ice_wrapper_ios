<template lang="html">
  <div @actions:closed="closeLog()">
    <div :hidden="!isLogOpened" class="e3i-prompt-overlay" @click="closeLog" style="background: rgba(0,0,0,.3);"></div>
    <f7-actions animated="true" :opened="isLogOpened" style="margin-left: 0; left: 0; width: 100%">
      <f7-actions-group class="log-wrapper">
        <f7-actions-label>
          <div class="log-title-wrapper flex">
            <i
              class="f7-icons menu-icon" style="font-size: 20px; color:#c7c8cc; margin-left: -10%;"
              @click="backToLogs" v-if="logIsDisplayed">chevron_left</i>
            <span v-if="!logIsDisplayed" class="log-title">{{$t("Logs")}}</span>
            <span v-else-if="logIsDisplayed && !isLocalLog" @click="backToLogs" class="log-title">{{unitName}}</span>
            <span v-else-if="logIsDisplayed && isLocalLog" @click="backToLogs" class="log-title">{{selectedLog[1]}}</span>
          </div>
          <!-- Log Share Icons-->
          <div class="flex log-share-wrapper" v-if="logIsDisplayed && !isLocalLog">
            <div v-if="logIsEmpty" class="flex">
              <i class="f7-icons log-email-icon disabled">email</i>
              <i class="f7-icons log-download-icon disabled">download</i>
            </div>
            <div v-else class="flex">
              <i class="f7-icons log-email-icon" @click="emailLog('log')">email</i>
              <i v-if="!logCurrentlySaving" class="f7-icons log-download-icon" @click="saveLog">download</i>
              <div v-else-if="logCurrentlySaving && !logWasSaved" class="flex" style="padding: 10px;">
                <div class="preloader preloader-gray" style="width: 20px; height: 20px;"></div>
              </div>
              <i v-else class="f7-icons log-download-icon e3i-success" style="padding: 8px 15px">check_round</i>
            </div>
          </div>
          <!-- Local Log Share Icons -->
          <div class="flex log-share-wrapper" v-else-if="logIsDisplayed && isLocalLog">
            <div v-if="localLogIsEmpty" class="flex">
              <i class="f7-icons log-email-icon disabled" >email</i>
              <i class="f7-icons log-download-icon disabled">trash</i>
            </div>
            <div v-else class="flex">
              <i class="f7-icons log-email-icon" @click="emailLog('locLog')">email</i>
              <i class="f7-icons log-download-icon" @click="openDeletePrompt(selectedLog[0], selectedLog[1])">trash</i>
            </div>
          </div>
        </f7-actions-label>
        <f7-list v-if="!logIsDisplayed">
          <!--  Request Log Start  -->
          <f7-list-item v-if="selectedUnitIndex != -1"
            :title="$t('Request Current Log')"
            class="menu-item"
            @click="requestLog"
          >
            <i class="f7-icons menu-icon" style="font-size: 20px; color:#c7c8cc;">arrow_right</i>
          </f7-list-item>
          <f7-list-item v-else
            :title="$t('Request Current Log')"
            class="menu-item disabled"
          >
            <i class="f7-icons menu-icon" style="font-size: 20px; color:#c7c8cc;">arrow_right</i>
          </f7-list-item>
          <!-- Local Log Start -->
          <f7-list-item style="padding: 0;">
            <div class="list-block accordion-list" style="width: 100%;">
                <li id="savedLogs" class="accordion-item">
                  <a href="#" class="item-content item-link">
                    <div class="item-inner" >
                      <div class="menu-item item-title" style="width:100%;">{{$t("Saved Logs")}}</div>
                    </div>
                  </a>
                <!-- If no logs saved -->
                  <div class="accordion-item-content menu-drop-down local-logs-list-wrapper">
                    <div v-if="localLogs.length === 0" class="content-block">
                      <div class="flex" style="justify-content: flex-start;">
                        <p>{{$t("No saved logs")}}</p>
                      </div>
                    </div>
                    <!-- Log displays -->
                    <ul v-else>
                      <div v-for="(dir, dindex) in localLogs" class="local-log-list">
                        <li class="accordion-item"><a href="#" class="item-content item-link" style="background-color: #fcfcfc;">
                          <div class="item-inner">
                            <div class="item-title menu-item">
                              <i class="f7-icons" style="font-size:15px; padding-right: 5px;">folder</i>
                              {{ dir[0] }}
                            </div>
                          </div></a>
                          <div class="accordion-item-content" v-for="(file, findex) in dir[1]">
                            <li :id="'file' + dindex + findex" class="swipeout">
                              <div class="content-block swipeout-content item-content" style="border-top: 1px solid #fcfcfc;">
                                <div class="item-media" style="width: 100%; padding: 0;">
                                  <div class="item-inner" style="padding-right:0; background: none;" @click="requestLocLog(localLogs[dindex][0], localLogs[dindex][1][findex])">
                                    <div class="menu-item item-title" style="width:100%;">
                                      {{file}}
                                      <i class="f7-icons menu-icon" style="font-size:19px; float: right; color: #c7c8cc;">arrow_right</i>
                                    </div>
                                  </div>
                                </div>
                              </div>
                              <div class="swipeout-actions-right" @click="openDeletePrompt(localLogs[dindex][0], localLogs[dindex][1][findex], dindex, findex)">
                                <a href="#" class="swipeout local-log-delete"><i class="f7-icons" style="font-size:19px; float: right;">trash</i></a>
                              </div>
                            </li>
                          </div>
                        </li>
                      </div>
                    </ul>
                  </div>
                </li>
            </div>
            <!-- deleteLog(localLogs[dindex][0], localLogs[dindex][1][findex]) -->
          </f7-list-item>
        </f7-list>
        <LogDisplay
          v-else
          :hidden="!logIsDisplayed"
          :isLocalLog="isLocalLog"
          :log="log"
          :localLogData="localLogData"
          :logIsEmpty="logIsEmpty"
          :localLogIsEmpty="localLogIsEmpty"
          class="log-data-display"
        >
        </LogDisplay>
        <div :hidden="!deleteOpened" class="e3i-prompt-overlay-delete" @click="closeDeletePrompt"></div>
        <DeletePrompt
          :deleteOpened="deleteOpened"
          :displayName="selectedLog[1]"
          @deleteClosed="closeDeletePrompt"
          @deleteLog="deleteLog(selectedLog[0], selectedLog[1])"
        ></DeletePrompt>
        <f7-actions-button @click="closeLog"
          class="e3i-gray-light log-button"
        >
          <i class="f7-icons" style="font-size:17px; color: #5a5a5a; padding-right: 5px;">close</i>
          {{$t("close")}}
        </f7-actions-button>
      </f7-actions-group>
    </f7-actions>
  </div>
</template>

<script>
import LogDisplay from './LogDisplay.vue'
import DeletePrompt from './DeletePrompt.vue'
import { promptBus } from '../../main'
export default {
  components: {
    LogDisplay,
    DeletePrompt
  },
  props: {
    selectedUnitIndex: Number,
    isLogOpened: Boolean,
    log: Array,
    localLogs: Array,
    localLogData: Array,
    logCurrentlySaving: Boolean,
    unitName: String,
    logWasSaved: Boolean,
  },
  computed:{
    logIsEmpty: function() {
    return  this.log.length === 0;
    },
    localLogIsEmpty: function() {
    return  this.localLogData.length === 0;
    }
  },
  methods: {
    closeLog: function(){
      this.logIsDisplayed = false
      this.$emit('logClosed');
      window.vue.$f7.accordionClose('#savedLogs')
    },
    openDeletePrompt: function(dir, file, dindex, findex) {
      this.selectedLog[0] = dir;
      this.selectedLog[1] = file;
      this.deleteOpened = true;
      window.f7.swipeoutClose('#file' + dindex + findex)
      console.log('delete Prompt', this.selectedLog)
    },
    closeDeletePrompt: function() {
      this.deleteOpened = false;
    },
    saveLog: function(){
      this.$emit('logCurrentlySaving')
      var str = this.log.join('\n')
      window.app.saveLog(encodeURIComponent(this.unitName), encodeURIComponent(str));
    },
    deleteLog: function(dir, file) {
      console.log('delete log: ' + dir + '/' + file);
      setTimeout(function(){
        window.app.deleteFile(encodeURIComponent(dir), encodeURIComponent(file));
      },500)
      this.logIsDisplayed = false
    },
    backToLogs: function(){
      this.logIsDisplayed = false;
    },
    requestLog: function() {
      window.app.sendCommand("lr");
      this.logIsDisplayed = true;
      this.isLocalLog = false;
    },
    requestLocLog: function(dir, file){
      console.log("window.app.reqContents://" + dir + '/' + file)
      window.app.reqContents(dir,file);
      this.selectedLog[0] = dir;
      this.selectedLog[1] = file;
      this.logIsDisplayed = true;
      this.isLocalLog = true;
      //console.log("selected log: ", this.selectedLog)
    },
    emailLog: function(log){
      if(log === 'log'){
        var month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth(); //January is 0!

        var yyyy = today.getFullYear();
        if(dd<10){
            dd='0'+dd;
        }
        var today = month[mm] + ' ' + dd + ' , '+yyyy;
        window.open('mailto:?subject=' + this.unitName + ' Log ' + today + '&body=' + this.convertLogToEmail(this.log));
      }else if(log === 'locLog'){
        window.open('mailto:?subject=' + 'Saved Log ' + this.selectedLog[0] + ' from ' + this.selectedLog[1] + '&body=' + this.convertLogToEmail(this.localLogData));
      }
    },
    convertLogToEmail: function(log) {
      var i = 1;
      var logStr = log.map( function(line){
        var str = i + ' ' + line
        i++;
        return str
      }).join('\n');
      return encodeURIComponent(logStr);
    }
  },
  data: function() {
    return {
      logIsDisplayed: false,
      isLocalLog: false,
      deleteOpened: false,
      selectedLog:[]

    }
  }
}
</script>
