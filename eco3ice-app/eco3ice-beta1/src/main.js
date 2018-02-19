import Vue from 'vue'
import Home from './home.vue'
import Routes from './routes.js'
import LANG from './lang'
import Framework7Vue from 'Framework7Vue'
import VueI18n from 'vue-i18n'




Vue.use(Framework7Vue);
Vue.use(VueI18n);


const i18n = new VueI18n({
  locale: 'en',
  messages: LANG
});


export const promptBus = new Vue();



// new Vue({ i18n }).$mount('#app')
window.vue = new Vue({
  el: '#app',
  render: h => h(Home),
  // Framework7 Parameters
  framework7: {
      root: '#app', //Should be same as app el
      animateNavBackIcon: true,
      routes: Routes
  },
  i18n,
  mounted: function(){
    window.app.reqUserData();
    window.app.inApp();
    this.$children[0].toggleConnect();
    setTimeout(function(){window.app.scanBle()}, 100);
  }
});
