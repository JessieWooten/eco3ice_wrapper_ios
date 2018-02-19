<template lang="html">
  <div id="app">
    <f7-views navbar-through="">
      <f7-view main="" url="/" :dynamic-navbar="true">
        <!-- Menu Panel-->
        <panel
          :is-panel-opened="panelOpened"
          :selectedUnitIndex="selectedUnitIndex"
          :imperial="imperial"
          :unitName="unitName"
          :language="language"
          @openResetPrompt="toggleResetPrompt()"
          @openConnectPrompt="toggleConnect(), requestUnit()"
          @closePanel="togglePanel(), closeAccordion()"
          @switchMeasurements="toggleMeasurements()"
          @setNewName="setNewName($event),togglePanel()"
          @setCapacity="setCapacity($event)"
          @setLang="setLang($event)"
          @openLog="toggleLog()"
          @openDisconnectPrompt="toggleDisconnectPrompt()"
        ></panel>
        <!-- Reset Prompt -->
        <reset-prompt
          :is-reset-opened="resetOpened"
          :unit-name="unitName"
          @resetClosed="toggleResetPrompt()"
          @resetUnit="resetUnit()"
          @closeAll="togglePanel()"
        ></reset-prompt>
        <!-- Connect Prompt -->
        <connect-prompt
          :isConnectOpened='connectOpened'
          :unitList="unitList"
          :selectedUnitIndex="selectedUnitIndex"
          @connectPromptClosed="toggleConnect()"
          @unitSelected="setSelectedUnit($event)"
        ></connect-prompt>
        <!-- Disconnect Prompt -->
        <disconnect-prompt
          :isDisconnectOpened="disconnectOpened"
          :unit-name="unitName"
          @disconnectClosed="toggleDisconnectPrompt()"
          @disconnectUnit="disconnectUnit()"
        ></disconnect-prompt>
        <!-- Log View -->
        <log
          :log="log"
          :localLogs="localLogs"
          :localLogData="localLogData"
          :unitName="unitName"
          :selectedUnitIndex="selectedUnitIndex"
          :isLogOpened="logOpened"
          :logCurrentlySaving="logCurrentlySaving"
          :logWasSaved="logWasSaved"
          @logClosed="toggleLog"
          @logCurrentlySaving="logSavingToggle"
        >
        </log>
        <!--Popup prompts -->
        <popup
          :popupOpened="popupOpened"
          :popupSaveOpened="popupSaveOpened"
          :popupWasReset="popupWasReset"
          :popupResetOpened="popupResetOpened"
          :connectToWifi="connectToWifi"
          :ipChanged="ipChanged"
          @closeWifiPrompt="toggleWifiPrompt"
          @closeIpPrompt="toggleIpPrompt"
          @closePopups="closePopups"
        ></popup>
        <!--Page start -->
        <f7-pages id="pages">
          <!-- Navigation Bar -->
          <navigation @togglePanel="togglePanel()"></navigation>
          <f7-page class="navbar-fixed" pull-to-refresh @ptr:refresh="pullToRefresh" color="white">
            <!-- Pull to refresh -->
            <div class="pull-to-refresh-layer">
              <div class="preloader preloader-white"></div>
              <div class="pull-to-refresh-arrow"><i class="f7-icons color-white">arrow_down</i></div>
            </div>
            <div :class="{'unit-name-container': true, 'bottom-space__title': this.version === ''}">
              <div v-if='nameIsLoading' class="flex" style="margin-top: 22px;">
                <div class="preloader preloader-white"></div>
              </div>
              <h2 v-else class="unit-name">{{ unitName }}</h2>
              <span v-if="this.version!= ''" class="unit-version">v.{{ version }}</span>
            </div>
          <!-- main content start -->
            <f7-swiper class="e3i-overflow" pagination>
              <f7-swiper-slide>
                <operation
                  :status="cleanUpInput(status)"
                  :health="cleanUpInput(health)"
                  :waterUsage="waterUsage"
                  :imperial="imperial"
                  :selectedUnitIndex="selectedUnitIndex"
                  @toggleDisconnectPrompt="toggleDisconnectPrompt()"
                ></operation>
              </f7-swiper-slide>
              <!-- <f7-swiper-slide>
                <consumption
                  :consumption="consumption"
                  :averageDuty="averageDuty"
                  :averageConsumption="averageConsumption"
                  :imperial="imperial"
                  :selectedUnitIndex="selectedUnitIndex"
                  @toggleDisconnectPrompt="toggleDisconnectPrompt()"
                ></consumption>
              </f7-swiper-slide> -->
              <f7-swiper-slide>
                <page-3
                  @OpenOrderParts="toggleOrderPrompt()"
                ></page-3>
              </f7-swiper-slide>
            </f7-swiper>
          <!-- main content end -->
          </f7-page>
        </f7-pages>
      </f7-view>
    </f7-views>
  </div>
</template>

<script>
import Navigation from './components/Navigation.vue'
import Operation from './components/Operation.vue'
import Consumption from './components/Consumption.vue'
import Page3 from './components/Page3.vue'
import Panel from './components/Panel.vue'
import ResetPrompt from './components/menu/Reset.vue'
import ConnectPrompt from './components/menu/Connect.vue'
import DisconnectPrompt from './components/menu/Disconnect.vue'
import Log from './components/menu/Log.vue'
import OrderParts from './components/menu/OrderParts.vue'
import Popup from './components/menu/Popup.vue'
export default {
  name: 'app',
  components: {
    Navigation,
    Operation,
    Consumption,
    Page3,
    Panel,
    ResetPrompt,
    DisconnectPrompt,
    ConnectPrompt,
    Log,
    OrderParts,
    Popup
  },
  computed: {
  },
  methods: {
	dataUpdate: function(str) {

		if(str == "connected") {
			setTimeout(function() { window.app.sendCommand("dr");},500);

		}else if(str.indexOf('do:') > -1) {
			try {
				var sdata = JSON.parse(str.substring(3));
				this.status = sdata.status;
				this.health = sdata.health;
				this.waterUsage = sdata.volume;
        this.consumption = sdata.consumption;
        this.averageDuty = sdata.avg_duty;
        this.averageConsumption = sdata.avg_consumption;
			  this.version = sdata.version ? sdata.version : '';
			} catch(e) { console.log(e,"error"); }
			try { window.prDone(); } catch(e) { };

		}else if(str.indexOf('new_device') > -1){
      this.unitList = JSON.parse(str.substring(11))
    }else if (str.indexOf("eset_saved") > -1) {
      setTimeout(function() { window.app.sendCommand("dr");},500);
      this.popupResetOpened = false;
      this.popupWasReset = true;
      var self = this;
      setTimeout(function(){self.popupWasReset = false}, 1000)

    }else if(str.indexOf('name_saved') > -1){
      var xhttp = new XMLHttpRequest();
      var self = this;
      var request = "http://" + this.mac + ':80/info'
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
          var device = JSON.parse(this.responseText);
          self.unitName = device.name;
          self.nameIsLoading = false;
          self.popupOpened = false;
          self.popupSaveOpened = true;
          self.closeAccordion()
          var that = self
          setTimeout(function(){that.popupSaveOpened = false}, 1000)
         }
      };
      xhttp.open("GET", request, true);
      xhttp.send();

    }else if(str.indexOf('capacity_saved')> -1){
      this.popupOpened = false;
      console.log('capacity saved.')
      this.popupSaveOpened = true;
      var self = this;
      setTimeout(function(){self.popupSaveOpened = false}, 1000)

    } else if(str.indexOf('log_ready') > -1) {
      var newdata = str.substring(10);
      for(var a =0;a<newdata.length;a++) {
        if(newdata[a] == '$') {
            this.incomingLog = "";
        } else if(newdata[a] == '~') {
            //finished
            console.log('done');
            //console.log(this.incomingLog.split('\n'));
            var tmplist = this.incomingLog.split('\n');
            for(var l =0;l< tmplist.length;l++) {
              if(tmplist.length > 0) {
                this.log.push(tmplist[l]);
              }
            }
            tmplist= null;

            break;
        }else {
          this.incomingLog += newdata[a];
        }
      }

    }else if(str.indexOf('local_logs') != -1){
      var arr= JSON.parse(str.substring(11));
      //loops through array and if directory is empty, deletes that empty directory
      arr.map(function(dir) {
        if(dir[1].length === 0){
          window.app.deleteFile(encodeURIComponent(dir[0]))
          console.log(dir[0] + " was empty. Deleting...")
        }
      });
      this.localLogs = arr;
      //console.log( 'The local logs are: ', this.localLogs)

    }else if(str.indexOf('loc_log_file_data') != -1){
      var contents = decodeURIComponent(str.substring(18));
      var arr = contents.split('\n');
      console.log("local log file: ", arr)
      this.localLogData = arr;

    }else if(str.indexOf('log_saved') != -1){
      window.app.reqLocalLogs()
      this.logWasSaved = true;
      var self = this;
      setTimeout(function(){self.logWasSaved = false; self.logCurrentlySaving = false;}, 1000)

    }else if(str.indexOf('log_deleted') != -1){
      window.app.reqLocalLogs();

    }else{
      console.log("ERROR - didnt fit dataUpdate case: " + str)
    }

	},
    requestUnit: function() {
      var dcount = 0;
	    this.unitList = [];
      var list = this.unitList;
      window.app.scanBle();
      let self = this;
      setTimeout(function(){
        if (self.unitList.length === 0){
          self.requestUnit();
        }
      }, 10000)
    },
    closeAccordion: function() {
      var self = this;
      setTimeout(function(){
        if(self.selectedUnitIndex != -1) {
          window.vue.$f7.accordionClose('#rename')
          window.vue.$f7.accordionClose('#capacity')
        }
        window.vue.$f7.accordionClose('#language')
        window.vue.$f7.accordionClose('#measurements')
      },300)
    },
    toggleOrderPrompt: function(prop) {
      this.orderPartsOpened = !this.orderPartsOpened
    },
    closePopups: function() {
      this.connectToWifi = false;
      this.ipChanged = false;
    },
    toggleWifiPrompt:function() {
      this.connectToWifi = !this.connectToWifi
    },
    toggleIpPrompt:function() {
      this.ipChanged = !this.ipChanged
    },
    togglePanel: function() {
      this.panelOpened = !this.panelOpened;
    },
    toggleResetPrompt: function() {
      this.resetOpened = !this.resetOpened;
    },
    toggleLog: function() {
      this.logOpened = !this.logOpened;
    },
    toggleConnect: function() {
      this.connectOpened = !this.connectOpened;
    	if(!this.connectOpened) {
    		window.clearInterval(window.tmpinterval);
    		window.clearTimeout(window.tmptimeout);
	    }
    },
    toggleDisconnectPrompt: function() {
      this.disconnectOpened = !this.disconnectOpened;
    },
    toggleMeasurements: function() {
      this.imperial = !this.imperial;
      window.app.userData('imperial', this.imperial);
    },
    logSavingToggle: function() {
      this.logCurrentlySaving = true;
      var self = this;
      setTimeout(function(){ self.logCurrentlySaving = false;}, 5000)
    },
    cleanUpInput: function(input) {
      return input.toLowerCase().trim();
    },
    displayIsLoading: function() {
      this.status = 'loading';
      this.health = 'loading';
      this.waterUsage = 'loading';
      this.consumption = 'loading';
      this.averageDuty = 'loading';
      this.averageConsumption= 'loading';
    },
    setSelectedUnit: function(index) {
    	window.clearInterval(window.tmpinterval);
    	window.clearTimeout(window.tmptimeout);
    	var device = this.unitList[index];
    	this.unitName = device.name;
      this.mac = device.mac;
      this.selectedUnitIndex = index;
      this.displayIsLoading()
    	window.app.connect(device.mac);
      if(this.panelOpened) {
        this.panelOpened = false;
      }
    },
    setNewName: function (name) {
      if(window.app.isConnected() && this.selectedUnitIndex != -1){
        window.app.sendCommand('rename:' + encodeURIComponent(name));
        this.nameIsLoading = true;
        this.popupOpened = true;
        var self = this;
        setTimeout(function(){
          if(self.popupOpened){
            self.popupOpened = false;
          }
        }, 10000)
      }
    },
    setCapacity: function(capacity){
      if(window.app.isConnected() && this.selectedUnitIndex != -1){
        window.app.sendCommand('capacity:' + capacity)
        console.log("window.app.sendCommand('capacity:' + capacity)")
        this.popupOpened = true;
        var self = this;
        setTimeout(function(){
          if(self.popupOpened){
            self.popupOpened = false;
          }
        }, 10000)
      }
    },
    setLang: function(lang) {
      alert(lang);
    },
    resetUnit: function() {
      if(window.app.isConnected() && this.selectedUnitIndex != -1){
        this.displayIsLoading();
        this.popupResetOpened = true;
        window.app.sendCommand('reset');
      }
    },
    disconnectUnit: function() {
      if(window.app.isConnected() && this.selectedUnitIndex != -1){
        this.panelOpened = false;
        this.unitName = '- - -';
        this.status = '---';
        this.mac = '';
        this.health = '---';
        this.waterUsage = '---';
        this.consumption = '---';
        this.averageDuty = '---';
        this.averageConsumption= '---';
        this.selectedUnitIndex = -1;
        this.version = '';
        window.app.disconnect();
      }
    },
    pullToRefresh: function (event, done) {
	    window.prDone = done;
      if(window.app.isConnected() && this.selectedUnitIndex != -1){
        window.app.sendCommand("dr");
      }else{
        done();
      }
      setTimeout(function(){
        try{
          done();
        } catch(e){}
      }, 5000)
    }
  },
  data () {
    return {
      panelOpened: false,
      resetOpened: false,
      connectOpened: false,
      disconnectOpened: false,
      popupOpened: false,
      popupResetOpened: false,
      popupWasReset:false,
      popupSaveOpened: false,
      orderPartsOpened: false,
      nameIsLoading: false,
      connectToWifi: false,
      ipChanged: false,
      logOpened: false,
      imperial: true,
      logCurrentlySaving: false,
      logWasSaved: false,
      language: 'en',
      unitName: '- - -',
      mac: '',
      version: '',
      status: '---',
      health: '---',
      waterUsage: '---',
      consumption: '---',
      averageConsumption: '---',
      averageDuty:'---',
      selectedUnitIndex: -1,
      incomingLog: '',
      log: [],
      localLogs: [],
      localFiles: [],
      localLogData:[],
      unitList: []
    }
  }
}
</script>

<!-- Hard coded test data

{
  name: 'Eco Unit 1',
  status: 'OK',
  health: 'Good',
  volume: '970',
  consumption:'800',
  duty:'600',
  avg_consumption:'760',
  avg_duty:'590'
},
{
  name: 'Eco Unit 2',
  status: 'Check Cartridge Health',
  health: 'Change Now',
  volume: '1200',
  consumption:'800',
  duty:'600',
  avg_consumption:'760',
  avg_duty:'590'
},
{
  name: 'Eco Unit 3',
  status: 'Excessive Flow Detected',
  health: 'Change Soon',
  volume: '3000',
  consumption:'635',
  duty:'344',
  avg_consumption:'1404',
  avg_duty:'479'
} -->
