$(document).ready(function() {
  // users#new validations
  $("form#new_user").submit(function(evt) {
    setupRemoveUnwrap();

    var name  = $(this).find("input#user_name");
    var email = $(this).find("input#user_email");
    var password     = $(this).find("input#user_password");
    var confirmation = $(this).find("input#user_password_confirmation");

    validate_name(name);
    validate_email(email);
    validate_password(password, confirmation);

    checkForErrors(evt, $(this));
  });

  // sessions#new validations
  $("form#new_session").submit(function(evt) {
    setupRemoveUnwrap();

    var email    = $(this).find("input#session_email");
    var password = $(this).find("input#session_password");

    validate_email(email);
    validate_password(password);

    checkForErrors(evt, $(this));
  });

  // account#edit validations
  $("form.edit_user[action='/profile/account']").submit(function(evt) {
    setupRemoveUnwrap();

    var name  = $(this).find("input#user_name");
    var email = $(this).find("input#user_email");

    validate_name(name);
    validate_email(email);

    checkForErrors(evt, $(this));
  });

  // password#edit validations
  $("form.edit_account").submit(function(evt) {
    setupRemoveUnwrap();

    var password     = $(this).find("input#account_password");
    var confirmation = $(this).find("input#account_password_confirmation");

    validate_password(password, confirmation);

    checkForErrors(evt, $(this));
  });

  // polls#new validations
  $("form#new_poll").submit(function(evt) {
    setupRemoveUnwrap();

    var textArea     = $("form#new_poll textarea");
    var pollPicture  = $("form#new_poll #poll_picture")[0].files[0];
    var choiceInputs = $(".choice");

    var has_empty_choice     = false;
    var has_duplicate_choice = false;
    var choice_too_long      = false;

    if(isBlank(textArea)) {
      errors.push('your poll question cannot be blank');
      wrapFieldWithErrors($(textArea));
    }
    if(isTooLong(textArea, 250)) {
      errors.push('please keep your poll less than 250 characters');
      wrapFieldWithErrors($(textArea));
    }
    if(!(pollPicture === undefined)) {
      var pollPictureSize = pollPicture.size/1024/1024;
      if(pollPictureSize > 3) {
        errors.push('Picture must be less than 3MB, current size is ' + pollPictureSize.toFixed(2) + 'MB');
      }
    }

    if(choiceInputs.length < 2) {
      errors.push('you must provide at least <strong>2</strong> choices');
    }

    for(var i = 0; i < choiceInputs.length; i++) {
      var input = choiceInputs[i];

      if (isBlank($(input))) {
        wrapFieldWithErrors($(input));
        has_empty_choice = true;
      }

      if (isTooLong($(input), 50)) {
        wrapFieldWithErrors($(input));
        choice_too_long = true
      }

      for(var j = i + 1; j < choiceInputs.length; j++) {
        if(isDuplicate($(input), $(choiceInputs[j]))) {
          wrapFieldWithErrors($(input))
          wrapFieldWithErrors($(choiceInputs[j]))
          has_duplicate_choice = true;
        }
      }
    }

    if(has_empty_choice)     { errors.push('your choices cannot be empty') }
    if(has_duplicate_choice) { errors.push('your choices must be unique') }
    if(choice_too_long)      { errors.push('please keep your choices less than 50 characters')}

    checkForErrors(evt, $(this));
  });

  // add a choice
  $("#addChoice").click(function(evt) {
    evt.preventDefault();

    var newId   = 'poll_choices_attributes_'  + choices.toString() + '_value';
    var newName = 'poll[choices_attributes][' + choices.toString() + '][value]';
    choices += 1;

    var newFormGroup  = document.createElement("div");
    var newInputGroup = document.createElement("div");
    var newLabel  = document.createElement("label");
    var newInput  = document.createElement("input");
    var newSpan   = document.createElement("span");
    var newButton = document.createElement("button");

    $(newFormGroup).addClass('form-group').append(newLabel).append(newInputGroup);
    $(newLabel).addClass('sr-only').text('Answer').attr('for', newId);
    $(newInputGroup).addClass('input-group').append(newInput).append(newSpan);
    $(newInput).addClass('form-control choice').attr({'id': newId, 'name': newName, 'type': 'text', 'placeholder': 'Choice'});
    $(newSpan).addClass('input-group-btn').append(newButton);
    $(newButton).addClass('btn btn-danger deleteChoice').attr('type', 'button').html('&times;');

    $(this).parent().before(newFormGroup);
    $(newInput).focus();
  });

  // delete a choice
  $("form#new_poll").on('click', '.deleteChoice', function() {
    $(this).parents('div.form-group').remove();
  });
})
