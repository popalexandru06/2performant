//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
  $(function(){
    $('#import-form').submit(function (e) {
      if ($(this).find('input[name="file"]').val() == '') { 
        e.preventDefault();
        alert('Select a file first');
      }     
    });
  });
});