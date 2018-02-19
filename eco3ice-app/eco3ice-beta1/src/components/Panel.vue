<template lang="html">
  <div @accordion:close="clearInputs()">
    <div :hidden="!isPanelOpened" class="e3i-prompt-overlay" @click="closePanel"></div>
    <f7-panel left cover :opened='isPanelOpened'>
      <div class="menu-logo-container">
        <img class="menu-logo" src="static/images/franke-logo.jpg" alt="Franke" @click="closePanel">
      </div>
      <f7-list>
        <!--Connect Prompt -->
        <f7-list-item
          :title="$t('Connect to machine')"
          class="menu-item"
          @click="openConnectPrompt"
        >
          <i class="f7-icons menu-icon">social_rss_fill</i>
        </f7-list-item>
        <!-- Disconnect Prompt Disabled-->
        <f7-list-item
          v-if="unitNotSelected"
          :title="$t('Disconnect Unit')"
          class="menu-item disabled"
        >
          <i class="f7-icons menu-icon disabled" style="font-size:23px;">close</i>
        </f7-list-item>
        <!--Disconnect Prompt Enabled -->
        <f7-list-item
          v-else
          :title="$t('Disconnect Unit')"
          class="menu-item"
          @click="openDisconnectPrompt"
        >
          <i class="f7-icons menu-icon" style="font-size:23px;">close</i>
        </f7-list-item>
        <!--Reset Prompt Disabled -->
        <f7-list-item
          v-if="unitNotSelected"
          :title="$t('Reset Unit')"
          class="menu-item disabled"
        >
          <i class="f7-icons menu-icon-reset disabled">refresh</i>
        </f7-list-item>
        <!--Reset Prompt Enabled -->
        <f7-list-item
          v-else
          :title="$t('Reset Unit')"
          class="menu-item"
          @click="openResetPrompt"
        >
          <i class="f7-icons menu-icon-reset">refresh</i>
        </f7-list-item>
        <!-- Accordion Start -->
        <f7-list-item style="padding: 0;">
          <div class="list-block accordion-list" style="width: 100%;">
            <!-- Rename Accordion -->
            <li v-if="unitNotSelected" class="accordion-item">
              <div class="item-inner" style="padding-right:0; background: none;">
                <div class="menu-item item-title disabled" style="width:100%;">
                  {{$t("Rename Unit")}}
                </div>
                <i class="f7-icons menu-icon" style="font-size:18px; float: right;">compose</i>
              </div>
            </li>
            <li v-else id="rename"class="accordion-item" @setNewName="close(event)"><a href="#" class="item-link" style="padding-left:0;" @click="matchNames('rename')">
              <div class="item-inner" style="padding-right:0; background: none;">
                <div class="menu-item item-title" style="width:100%;">
                  {{$t("Rename Unit")}}
                </div>
                <i class="f7-icons menu-icon" style="font-size:18px; float: right;">compose</i>
              </div></a>
              <div class="accordion-item-content">
                <div class="content-block">
                  <div class="menu-drop-down flex" style="justify-content: flex-start;">
                    <div>
                      <input class="menu-rename-input"
                        type="text"  ref="rename" maxlength="20"
                        v-model="newUnitName" v-on:keydown.enter="setName()"
                        style="margin: 5px 0; padding: 0 8px; font-weight: 300"/>
                    </div>
                    <button :disabled="nameTooShort || nameIsSame || unitNotSelected || hasForbiddenChars"
                      :class="{'menu-rename-button': true, 'menu-disabled-button': nameTooShort || nameIsSame || unitNotSelected || hasForbiddenChars }"
                      type="button" name="button" @click="setName()"
                      >
                      <i class="f7-icons" style="font-size: 17px;">chevron_right</i>
                    </button>
                  </div>
                </div>
              </div>
            </li>
            <!--Capacity Accordion -->
            <li v-if="unitNotSelected" class="accordion-item">
              <div class="item-inner" style="padding-right:0; background: none;">
                <div class="menu-item item-title disabled" style="width:100%;">
                  {{$t("Set Ice Machine Capacity")}}
                </div>
                <i class="f7-icons menu-icon" style="font-size:19px; float: right;">box</i>
              </div>
            </li>
            <li v-else id="capacity" class="accordion-item"><a href="#" class="item-link" style="padding-left:0;" >
              <div class="item-inner" style="padding-right:0; background: none;">
                <div class="menu-item item-title" style="width:100%;">
                  {{$t("Set Ice Machine Capacity")}}
                </div>
                <i class="f7-icons menu-icon" style="font-size:19px; float: right;">box</i>
              </div></a>
              <div class="accordion-item-content">
                <div class="content-block">
                  <div class="menu-drop-down flex" style="justify-content: flex-start;">
                    <div>
                      <input class="menu-capacity-input" type="text" maxlength="5"
                        v-model="capacityValue" v-on:keydown.enter="setCapacity()" placeholder="0"
                        style="margin: 5px 0; padding: 0 8px; font-weight: 300"
                        />
                        <span v-if="this.imperial" style="margin: 0 5px;"> {{$t("lbs")}}</span>
                        <span v-else style="margin: 0 5px;"> {{$t("kg")}}</span>
                    </div>
                    <button :disabled="!isWholeNumber || Number(this.capacityValue) === 0  || unitNotSelected"
                      :class="{'menu-rename-button':true, 'menu-disabled-button':!isWholeNumber || Number(this.capacityValue) === 0  || unitNotSelected }"
                      type="button" name="button"
                      @click="setCapacity()"
                    >
                      <i class="f7-icons" style="font-size: 17px;">chevron_right</i>
                    </button>
                  </div>
                </div>
              </div>
            </li>
            <!--Language Accordion -->
            <li id="language" class="accordion-item"><a href="#" class="item-link" style="padding-left:0;">
              <div class="item-inner" style="padding-right:0; background: none;">
                <div class="menu-item item-title" style="width:100%;">
                  {{$t("Language")}}

                </div>
                <i class="f7-icons menu-icon" style="font-size:17px; float: right;">world</i>
              </div></a>
              <div class="accordion-item-content">
                <div class="content-block" style="padding: 0">
                  <div class="menu-drop-down flex" style="justify-content: flex-start;">
                    <div class="flex" style="width: 100%;">
                    <LangSelect @closePanel="closePanel"></LangSelect>
                  </div>
                  </div>
                </div>
              </div>
            </li>
            <!--Measurements Accordion -->
            <li id="measurements" class="accordion-item"><a href="#" class="item-link" style="padding-left:0;">
              <div class="item-inner" style="padding-right:0; background: none;">
                <div class="menu-item item-title" style="overflow: visible;">
                  {{$t("Measurements")}}
                </div>
                  <img src="static/images/ruler.png" class="menu-icon-img">
              </div></a>
              <div class="accordion-item-content">
                <div class="content-block">
                  <div class="menu-drop-down flex" style="justify-content: flex-start;">
                    <p :class="{'menu-measurement': true, disabled: this.imperial}">{{$t("metric")}}</p>
                    <f7-input id="switch"
                    v-model="this.imperial"
                    type="switch"
                    @click="switchMeasurement"
                    name="measurement"
                    style="width:auto"></f7-input>
                    <p :class="{'menu-measurement': true, disabled: !this.imperial}">{{$t("imperial")}}</p>
                  </div>
                </div>
              </div>
            </li>
          </div>
        </f7-list-item>
        <!--Log Prompt Enabled -->
        <f7-list-item
          :title="$t('View Log')"
          class="menu-item"
          @click="openLog"
        >
          <i class="f7-icons menu-icon" style="font-size:17px;">document_text</i>
        </f7-list-item>
      </f7-list>
      <p :hidden="!nameTooShort" class="e3i-fail" style="font-size: 9px; margin-left: 15px">{{$t("name should be at least 3 characters long")}}</p>
      <p :hidden="isWholeNumber" class="e3i-fail" style="font-size: 9px; margin-left: 15px">{{$t("capacity should be a whole number")}}</p>
      <p :hidden="!hasForbiddenChars" class="e3i-fail" style="font-size: 9px; margin-left: 15px">{{$t("name contains forbidden characters")}}</p>
    </f7-panel>
  </div>
</template>

<script>
import { promptBus } from '../main'
import LangSelect from './menu/LangSelect.vue'
export default {
  components: {
    LangSelect
  },
  props: {
    isPanelOpened: Boolean,
    isResetOpened: Boolean,
    selectedUnitIndex: Number,
    imperial: Boolean,
    unitName: String,
    language: String
  },
  computed:{
    unitNotSelected: function() {
      return this.selectedUnitIndex === -1;
    },
    nameIsSame: function() {
      return this.unitName.trim() == this.newUnitName.trim()
    },
    nameTooShort: function() {
      return this.newUnitName.length < 3
    },
    hasForbiddenChars: function() {
      var letters = /^[0-9a-zA-Z\-_ ]+$/;
    if(this.newUnitName === ''){
      return false;
    }else if (letters.test(this.newUnitName)) {
      // alert('accepted');
      return false;
    } else {
      //alert('Please input alphanumeric characters only');
      return true;
    }
    },
    isWholeNumber: function() {
      let input = Number(this.capacityValue)
      if(isNaN(input)){
        return false
      }else if (this.capacityValue.indexOf('.') != -1) {
        return false;
      }else{
        return (typeof input == 'number' && input%1 == 0);
      }
    }
  },
  methods: {
    close: function(event){
      event.currentTarget.accordionClose()
    },
    openConnectPrompt: function() {
      this.$emit('openConnectPrompt');
    },
    openDisconnectPrompt: function() {
      this.$emit('openDisconnectPrompt');
    },
    openResetPrompt: function() {
      this.$emit('openResetPrompt');
    },
    openLog: function() {
      this.$emit('openLog');
      window.app.reqLocalLogs();

    },
    closePanel: function() {
      this.$emit('closePanel')
    },
    switchMeasurement: function() {
      this.$emit('switchMeasurements');
    },
    matchNames: function(id) {
      if(this.selectedUnitIndex != -1){
        this.newUnitName = this.unitName;
      }
    },
    setName: function() {
      this.$emit('setNewName', this.newUnitName);
      this.clearInputs();
    },
    clearInputs: function()  {
      this.newUnitName = this.unitName;
      this.capacityValue = '';
    },
    setCapacity: function() {
      if (this.imperial) {
        console.log('Set Capacity: ' + this.capacityValue + ' lbs')
        this.$emit('setCapacity', this.capacityValue),
        this.capacityValue = '';
      }else{
        let toLbs = Math.round(this.capacityValue * 2.20462262185);
        console.log(this.capacityValue + ' kg converts to ' + toLbs + ' lbs')
        this.$emit('setCapacity', toLbs);
        this.capacityValue = '';
      }
    }
  },
  data: function() {
    return {
      capacityValue: '',
      newUnitName: this.unitName,
      warnName: false
    }
  }
}
</script>
