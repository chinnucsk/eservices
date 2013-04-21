
(function(){
  
  (function(){
  var s =  document.createElement('script');
  s.setAttribute('src', 'http://pipes.yahoo.com/pipes/pipe.run?_id=e81c01c75b8a0c0af41921b764b46208&_render=json&_callback=test');
  s.setAttribute('id', 'json_data');
  document.getElementsByTagName('body')[0].appendChild(s);
  })();
  
  var s = document.getElementById('json_data');
})();


function test(data) {
    console.debug(data);
}