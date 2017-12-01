$('.logo1').animate( { opacity: 1 }, {
    duration: 1000,
    step: function (now) {
      $(this).css({ transform: 'rotate(' + now * -45 + 'deg)' })
    }
  });