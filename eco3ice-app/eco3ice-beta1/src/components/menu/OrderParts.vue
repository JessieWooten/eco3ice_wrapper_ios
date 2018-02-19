<template lang="html">
  <div @actions:closed="closeOrder()">
    <f7-actions :opened="orderPartsOpened">
      <f7-actions-group>
        <f7-actions-label class="purchase-prompt__title">{{$t("Purchase online")}}</f7-actions-label>
        <f7-list>
          <f7-list-item class="purchase-prompt__container flex" @click="launchWebstore()">
            <div class="box-title-left flex" style="border: 0;">
              <!-- SHOPPING CART -->
              <img src="static/images/browser.png" class="shopping-cart">
            </div>
          <p class="purchase-prompt__text">{{$t("go to webstore")}}</p>
          <i class="f7-icons purchase-arrow">arrow_right</i>
          </f7-list-item>
        </f7-list>
        <f7-actions-button @click="closeOrder()" class="e3i-gray-light" style="width: 100% !important;">{{$t("Cancel")}}</f7-actions-button>
      </f7-actions-group>
    </f7-actions>
  </div>
</template>

<script>
export default {
  props:{
    orderPartsOpened: Boolean
  },
  methods: {
    closeOrder: function() {
      this.$emit('orderPromptClosed');
    },
    launchWebstore: function() {
      window.app.orderParts('www.myfranke.com')
    }
  }
}
</script>
