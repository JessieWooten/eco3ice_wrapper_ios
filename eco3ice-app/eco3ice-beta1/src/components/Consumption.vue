<template lang="html">
  <div style="height: 80vh">
    <h3 class="page-title">{{$t("consumption")}}</h3>
    <!-- Daily Consumption Block Start -->
    <div class="content-block inset flex e3i-scale-lg">
      <div class="content-block-inner">
        <div class="e3i-content-lg">
          <div class="status-container">
            <!-- Default Daily Consumption-->
            <div v-if="consumption === '---'" class="status-wrapper">
              <p class="status-text-blank e3i-gray-light" style="letter-spacing: 1px;">---</p>
            </div>
            <!-- Daily Consumption is loading -->
            <div v-else-if="consumption === 'loading'" class="status-wrapper">
              <div class="preloader-health">
                <div class="preloader preloader-gray" style="width: 25px; height: 25px;"></div>
              </div>
            </div>
            <!-- Daily Consumption # in LBS-->
            <div v-else class="status-wrapper">
              <!--LBS-->
              <div v-if="this.imperial">
                <p class="consumption-text e3i-success">{{ consumption }}</p>
                <img class="status-icon-inline" src="static/images/consumption/lbs.png">
              </div>
              <!--KG-->
              <div v-else>
                <p class="consumption-text e3i-success">{{ convertToKg(consumption) }}</p>
                <img class="status-icon-inline" src="static/images/consumption/kg.png">
              </div>
            </div>
          </div>
          <div class="status-title-wrapper">
            <span class="box-title">{{$t("daily consumption")}}</span>
          </div>
        </div>
      </div>
    </div>
    <!-- Monthly Avg Consumption Block Start -->
    <div class="content-block inset flex e3i-scale-sm" >
      <div class="content-block-inner">
        <div class="e3i-content-sm flex">
          <div class="avg-consumption-wrapper__title">
            <div class="">
              <div class="box-title-left">
                <div>
                  <p class="avg-consumption__title" v-html="$t('monthly average consumption')"></p>
                </div>
              </div>
            </div>
          </div>
          <div class="avg-consumption-wrapper__display">
            <div class="avg-consumption-display__top flex">
              <!-- Average Monthly Consumption blank-->
              <div v-if="averageConsumption === '---'">
                <span class="avg-consumption-number e3i-gray-light">---</span>
              </div>
              <!-- Average Monthly Consumption Loading-->
              <div v-else-if="averageConsumption === 'loading'">
                <div class="preloader-health" style="left:10px; top: 10px;">
                  <div class="preloader preloader-gray" style="width: 25px; height: 25px;"></div>
                </div>
              </div>
              <!-- Average Monthly Consumption #-->
              <div v-else style="padding-top: 7px;">
                <!--LBS-->
                <div v-if="this.imperial">
                  <span class="avg-consumption-number e3i-success">{{ averageConsumption }}</span>
                    <img class="avg-consumption-icon" src="static/images/consumption/lbs.png">
                  <p class="avg-consumption-display__daily">{{$t("daily")}}</p>
                </div>
                <!--KG-->
                <div v-else>
                  <span class="avg-consumption-number e3i-success">{{ convertToKg(averageConsumption) }}</span>
                  <img class="avg-consumption-icon" src="static/images/consumption/kg.png">
                  <p class="avg-consumption-display__daily">{{$t("daily")}}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Monthly Avg Duty Cycle Block Start -->
    <div class="content-block inset flex e3i-scale-sm" >
      <div class="content-block-inner">
        <div class="e3i-content-sm flex">
          <div class="avg-consumption-wrapper__title">
            <div class="">
              <div class="box-title-left">
                <div>
                  <p class="avg-consumption__title" v-html="$t('monthly average duty cycle')"></p>
                </div>
              </div>
            </div>
          </div>
          <div class="avg-consumption-wrapper__display">
            <div class="avg-consumption-display__top flex">
              <!-- Average Monthly Duty cycle Loading-->
              <div v-if="averageDuty === 'loading'">
                <div class="preloader-health" style="left:10px; top: 10px;">
                  <div class="preloader preloader-gray" style="width: 25px; height: 25px;"></div>
                </div>
              </div>
              <!-- Average Monthly Duty cycle #-->
              <div v-else style="padding-top: 7px;">
                <PercentageChart
                  :averageDuty="averageDuty"
                ></PercentageChart>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class= "disconnect-wrapper" v-if="selectedUnitIndex != -1">
      <div class="disconnect-launcher" @click="toggleDisconnectPrompt()">
        <i class="f7-icons disconnect-icon">close</i>
      </div>
    </div>
  </div>
</template>

<script>
import PercentageChart from '../components/PercentageChart.vue'
export default {
  components:{
    PercentageChart
  },
  props: {
    consumption: String,
    averageDuty:String,
    averageConsumption: String,
    imperial: Boolean,
    selectedUnitIndex: Number
  },
  methods: {
    convertToKg: function(lbs) {
      if(!isNaN(Number(lbs))){
        const kg = 0.45359237;
        return Math.round(lbs * kg)
      }
    },
    toggleDisconnectPrompt: function() {
      this.$emit('toggleDisconnectPrompt')
    }
  },
  data: function() {
    return {

    }
  }
}
</script>
