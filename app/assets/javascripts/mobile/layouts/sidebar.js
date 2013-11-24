var menu = $('.menu');
var push = $('.push');

  var positionOffScreen = {
    'position': 'fixed',
    'top': '0',
    'bottom': '0',
    'width': '15.625em',
    'height': '100%'
  };

  menu.css(positionOffScreen);

  $('.menu-link').click(function() {
    menu.toggleClass("navpush");
    push.toggleClass("containerpush");
  });