<template lang="html">
  <div style="height: 80vh">
    <div class="content-block inset flex e3i-scale-sm" @click="orderParts()">
      <div class="content-block-inner">
        <div class="e3i-content-sm flex">
          <div class="purchase-wrapper__icon">
            <div>
              <div class="box-title-left flex">
                <!-- SHOPPING CART -->
                <img src="static/images/shopping_cart.png" class="shopping-cart">
              </div>
            </div>
          </div>
          <div class="purchase-wrapper__text">
            <div class="avg-consumption-display__top flex">
              <p class="purchase-text">{{$t("Order Parts")}} <i class="f7-icons purchase-arrow">arrow_right</i>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import orderParts from '../components/menu/OrderParts.vue'
export default {
  components: {
    orderParts
  },
  props: {
    orderPartsOpened: Boolean
  },
  methods: {
    orderParts: function() {
        window.app.orderParts('www.myfranke.com')
    }
  },
  data: function() {
    return {
    }
  }
}
</script>
