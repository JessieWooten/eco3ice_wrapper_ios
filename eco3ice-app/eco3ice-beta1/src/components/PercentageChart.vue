<template lang="html">
  <div>
    <!-- <svg>
      <circle r="30" cx="50%" cy="50%" class="circle1" />
      <circle r="30" cx="50%" cy="50%" :stroke-dasharray="avgDutyToPercent" class="circle2" />
    </svg> -->
    <section>
      <svg class="circle-chart" width="24vw" height="24vw" xmlns="http://www.w3.org/2000/svg">
        <circle id="percentageChart" class="circle-chart__background" stroke="#b6b2b2" stroke-width="2" fill="none" cx="50%" cy="50%" r="10vw" />
        <circle class="circle-chart__circle" stroke="#7ceced" :stroke-dasharray="getPercentage() + ',' + getCircumference()" stroke-width="2"  stroke-linecap="round" fill="none" cx="50%" cy="50%" r="10vw" />
        <g class="circle-chart__info">
          <text v-if="averageDuty === '---'" class="circle-chart__percent" x="50%" y="40%" alignment-baseline="central" text-anchor="middle" font-size="18" fill="#b6b2b2">---</text>
          <text v-else class="circle-chart__percent" x="50%" y="40%" alignment-baseline="central" text-anchor="middle" font-size="5vw" fill="#4ee038">{{ averageDuty }}%</text>
          <text class="circle-chart__subline" x="50%" y="60%" alignment-baseline="central" text-anchor="middle" font-size="5vw" font-weight="300" fill="#b6b2b2">{{$t("daily")}}</text>
        </g>
      </svg>
  </section>
  </div>
</template>

<script>
export default {
  props:{
    averageDuty: String
  },
  computed:{
  },
  methods: {
    avgDutyToPercent: function() {
      var self = this;
      setTimeout(function(){
        var circumference = self.getCircumference();
        if(self.averageDuty === '---'){
            return ("0, " + circumference);
        }else if(isNaN(self.averageDuty)){
          return "0, " + circumference;
        }else{
          var percentage = circumference * (self.averageDuty * .01)
          return percentage + ", " + circumference;
        }
      }, 200)
    },
    getPercentage:function(){
      var self = this;
        if(isNaN(self.averageDuty)){
          return "0"
        }else{
          var percentage = self.getCircumference() * (self.averageDuty * .01)
          return percentage
        }
    },
    getCircumference: function() {
        var r = document.documentElement.clientWidth / 10;
        return String(Math.round(3.14 * (r * 2)))
    }
  }
}
</script>
