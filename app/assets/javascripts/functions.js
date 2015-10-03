// global variables
var choices     = 2; // default is Yay/Nay
var emailFormat = /^[\w\+\-\.]+@[a-z\d\-\.]+[a-z\d\-]\.[a-z]+$/i

// validation functions
var validate_name = function(name) {
  if(isBlank(name)) {
    errors.push("Name can't be blank");
    wrapFieldWithErrors(name);
  }
};

var validate_email = function(email) {
  if(isBlank(email)) {
    errors.push("Email can't be blank");
    wrapFieldWithErrors(email);
  }
  if(invalidEmail(email)) {
    errors.push("Email is invalid");
    wrapFieldWithErrors(email);
  }
};

var validate_password = function(password, confirmation) {
  if(isBlank(password)) {
    errors.push("Password can't be blank");
    wrapFieldWithErrors(password);
    if(confirmation !== undefined) {
      wrapFieldWithErrors(confirmation);
    }
  }
  if(isTooShort(password, 6)) {
    errors.push("Password is too short (minimum is 6 characters)");
    wrapFieldWithErrors(password);
    if(confirmation !== undefined) {
      wrapFieldWithErrors(confirmation);
    }
  }
  if(confirmation !== undefined) {
    if(password.val() !== confirmation.val()) {
      errors.push("Password confirmation doesn't match Password");
      wrapFieldWithErrors(password);
      wrapFieldWithErrors(confirmation);
    }
  }
};

// helper functions
var setupRemoveUnwrap = function() {
  errors = [];
  $("#error_list").remove();
  $(".field_with_errors").children().unwrap();
};

var isBlank = function(element) {
  return element.val().replace(/\s/g, '').length === 0;
};

var isDuplicate = function(element1, element2) {
  return element1.val().toLowerCase() === element2.val().toLowerCase();
};

var isTooLong = function(element, len) {
  return element.val().length > len;
};

var isTooShort = function(element, len) {
  return element.val().length < len;
};

var invalidEmail = function(element) {
  return !emailFormat.test(element.val());
};

var wrapFieldWithErrors = function(element) {
  if(!element.parent().is('div.field_with_errors')) {
    element.wrap('<div class="field_with_errors"></div>');
  }
}

var renderErrorMessage = function(form) {
  var errorDiv = document.createElement("div");
  var alertDiv = document.createElement("div");
  var errorUl  = document.createElement("ul");

  $(errorDiv).attr('id', 'error_list').append(alertDiv).append(errorUl);
  $(alertDiv).addClass('alert alert-danger').text('please fix the following errors');
  for(var i = 0; i < errors.length; i++) {
    var errorLi  = document.createElement("li");
    $(errorLi).html(errors[i]);
    $(errorUl).append(errorLi);
  }
  form.prepend(errorDiv);
};

var checkForErrors = function(e, form) {
  if(errors.length > 0) {
    e.preventDefault();
    renderErrorMessage(form);
  }
}

// new comment
var checkComment = function() {
  var commentCount  = $("form#new_comment").find("span#comment-count");
  var commentLength = function() {
    var commentContent = $("form#new_comment").find("textarea#comment_message");
    return $.trim(commentContent.val()).length;
  };
  commentCount.text(140 - commentLength());
  var submitBtn = $("form#new_comment").find("input[type=submit]");

  if(commentLength() > 140) {
    submitBtn.attr("disabled", "disabled");
    commentCount.addClass('invalid');
    commentCount.removeClass('valid');
  } else {
    submitBtn.removeAttr("disabled");
    commentCount.addClass('valid');
    commentCount.removeClass('invalid');
  }
};
