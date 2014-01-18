$ ->
  currentData = null

  # Toggle View Lessons
  $('#toggle-show-lessons').on 'click', (event) ->
    $('#welcome-div').slideUp()
    $('#show-lessons').toggleClass('hide')

  ############################
  ### Creating New Lessons ###
  ############################

  # New Lesson modal
  $('#new-lesson').on 'click', (event) ->
    $('#modal-text').empty()
    $('#modal-text').append JST['templates/new_lesson']()

  # Category button
  $('body').on 'click', '#new-category', (event) ->
    $('#categories-list').append JST['templates/category'](" ")

  # Sub Concept button
  $('body').on 'click', '#new-concept', (event) ->
    list = $(this.parentElement.lastElementChild)
    list.append JST['templates/sub_concept']()

  # Submit new lesson
  $('#create-lesson').on 'click', (event) ->
    dataObj = createConceptObj($('.category-text'), $('.concept-text'))
    data =
      lesson: { title: $('#new-lesson-text').val() }
      categories: dataObj
    $.post('/lessons', data).done (data) ->
      $('#show-lessons').append JST['templates/lesson_small'](data)
      $('.modal').modal('hide')

  createConceptObj = (categories, concepts) ->
    conceptArray = []
    dataObj = {}
    for category in categories
      cat = $(category).val()
      concepts = $(category).parent().find('.concept-text')
      for concept in concepts
        conceptArray.push($(concept).val())
      dataObj[cat] = conceptArray
      conceptArray = []
    return dataObj

  #####################################
  ### Show Lesson and Update Rating ###
  #####################################

  # Show Lesson
  $('body').on 'click', '.show-lesson', (event) ->
    lessonID = $(this)[0].id
    $.get('/lessons/' + lessonID).done (data) ->
      $('#render-data').data('lesson-data', data)                      # IMPORTANT: We store data here so we don't need to ajax for editing later
      $('#index').slideUp()
      $('#render-data').append(JST['templates/show_lesson'](data)).slideDown()

  # Back to Main
  $('body').on 'click', '.back-to-main', (event) ->
    backToMain()

  backToMain = ->
    $('#render-data').slideUp()
    $('#index').slideDown()
    setTimeout $('#render-data').empty(), 500

  # Only one radio button can be selected at a time
  $('body').on 'click', ':radio', (event) ->
    $radios = $(this).parent().children('input')
    $radios.not(this).prop('checked', false)

  # Update rating
  $('body').on 'click', '.submit-rating', (event) ->
    event.preventDefault()
    selected = $(this).parent().children 'input:checked'
    data =
      value: selected.val()
      id: selected[0].id
    $.post('/lessons/vote', data).done (data) ->
      $('#rating-' + data.id).html "Rating: " + data.ratingAverage
      $('#count-' + data.id).html "Vote Count: " + data.ratingCount

  ###############################
  ### Edit and Delete Lessons ###
  ###############################

  # Update Lesson - Retrieve Data
  $('body').on 'click', '#update-lesson', (event) ->
    data = $('#render-data').data('lesson-data')       # Instead of ajax call, we use data already stored in DOM
    $('#edit-modal-text').empty()
    $('#edit-modal-text').append JST['templates/edit_lesson'](data)

  # Update Lesson - Submit Data
  $('body').on 'click', '#submit-updated-lesson', (event) ->
    dataObj = createConceptObj($('.category-text'), $('.concept-text'))
    data =
      lesson: { title: $('#new-lesson-text').val() }
      categories: dataObj
    console.log data
    debugger
    $.ajax
      url: "/lessons"
      type: "PUT"
      data: data
      success: (result) ->
        console.log result
        console.log "Success!"


  # Delete Lesson
  $('body').on 'click', '#delete-lesson', (event) ->
    event.preventDefault()
    id = this.parentElement.id
    if confirm "Are you sure you want to delete this lesson?"
      $.ajax
        url: "/lessons/" + id
        type: "DELETE"
        success: (result) ->
          $('#' + id).remove()
          backToMain()