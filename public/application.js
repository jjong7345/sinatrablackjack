$(document).ready(function() {
  $(document).on("click", "#hit_form input", function() {
    $.ajax({
      url: '/player/hit',
      type: 'POST'
    })
    .done(function(msg) {
      //console.log(msg);
      $("#game").replaceWith(msg)
    })
    .fail(function() {
      console.log("error");
    })
    .always(function() {
      console.log("complete");
    });
    return false; 
    
  });
  
});