<template>
  <div style="width: 100%;">
    <select class="menu-lang-select" v-model="selectedLang" name="langSelect">
      <option disabled value="" style="display: none;">{{currentLanguage(this.$i18n.locale)}}</option>
      <option v-for="(lang, index) in supportedLangs" :value="lang">{{currentLanguage(lang)}}</option>
    </select>
    <!-- <i :class="{'f7-icons':true, 'menu-icon':true, 'menu-submit-button': !isDisabled, 'menu-disabled-button':isDisabled}" :disabled="isDisabled"
    @click="setLang"
    >chevron_right</i> -->
    <button :disabled="isDisabled"
      :class="{'menu-rename-button':true, 'menu-disabled-button': isDisabled}"
      type="button" name="button"
      @click="setLang"
    >
      <i class="f7-icons" style="font-size: 17px;">chevron_right</i>
    </button>
  </div>
</template>

<script>
export default {
  data () {
    return {
      selectedLang: '',
      locale: 'en'

    }
  },
  computed:{
    supportedLangs: function() {
      var availableLangs = [];
      var i18n = this.$i18n.messages;
  	  for(var key in i18n) {
  		    availableLangs.push(key)
  	  }
  	  return availableLangs;
    },
    isDisabled: function(){
      if(this.selectedLang === this.$i18n.locale){
        return true;
      } else if(this.selectedLang === ''){
        return true;
      }else{
        return false;
      }
    }
  },
  methods:{
    setLang: function() {
      this.$i18n.locale = this.selectedLang;
      this.selectedLang = '';
      window.app.userData('locale', this.$i18n.locale)
      this.$emit('closePanel')
    },
    currentLanguage: function(lang) {
      switch (lang) {
        case 'en':
          return "English"
          break;

        case "es":
            return "español"
            break;

        default:
        return lang
      }
    }
  }
}
</script>
