Session.set 'xday', moment().toDate()
calendar_pop = new Meteor.Collection null
calendar_date = new Meteor.Collection null

$.valHooks['xcalendar'] =
    get: (el)->
        value = $(el).find('.xcalendar').val()
        if not value
            return null
        format = $(el).attr('format')
        moment.utc(value, format).toDate()
 
    set: (el, value)->   
        name = $(el).attr('data-schema-key')
        if _.isEqual(value, [""]) or value == '' # don't know why happens
            #$(el).find('.xcalendar').attr('value', '')  
            calendar_date.remove(name:name)        
            calendar_date.insert(name:name, value:'')
            return
        if _.isString(value)
            value = moment(value, "YYYY-MM-DD[T]HH:mm:ss.SSS[Z]")
        else if _.isDate(value)
            value = moment.utc(value)

        format = $(el).attr('format')
        value = value.format(format)
        
        calendar_date.remove(name:name)        
        calendar_date.insert(name:name, value:value)
        #$(el).find('.xcalendar').attr('value',value)

$.fn.xcalendar = (name)->
    this.each -> 
        this.type = 'xcalendar'
        calendar_pop.insert({name:name, visible:false})
    this

Template.xcalendar.rendered = -> 
    #$('.container-calendar').xcalendar($(@find('.xbutton')).attr('name'))
    $(this.find('.container-calendar')).xcalendar($(@find('.xbutton')).attr('name'))

Template.xcalendar.events
    'click .minus-month': (e,t)->
        Session.set('xday', moment(Session.get('xday')).add('months', -1).toDate())
    'click .plus-month': (e,t)->
        Session.set('xday', moment(Session.get('xday')).add('months', 1).toDate())
    'click .calendar-day': (e,t)->
        el=t.find('.container-calendar')
        $(el).val($(e.target).attr('date'))
    'click .xbutton': (e,t)->
        name=$(e.target).attr('name')
        visible = calendar_pop.findOne(name:name).visible
        calendar_pop.update({name:name}, {$set: {visible: not visible}})
    'click .set-hour': (e,t)->
        el=t.find('.container-calendar')
        hour = $(t.find('.xhour')).val()
        date = moment($(el).val()).startOf('Day').format('YYYY-MM-DD')
        $(el).val(date+' '+hour)

Template.xcalendar.helpers
    getValue: (name) ->
        item = calendar_date.findOne(name:name)
        if item
            item.value
        else
            null
    setInitial: (value, name)->
        el = $('[name='+name+']').parent()
        el.val(value) # set the value on the container
        null 

    visible: (name)-> 
        item=calendar_pop.findOne(name:name)
        if not item or not item.visible
            'invisible'
    week: -> (i for i in [0...6])
    day: (week) -> 
        ret = []
        day=Session.get 'xday'
        day=moment(day)
        ini_month = day.clone().startOf('Month')
        ini = day.clone().startOf('Month').add('days', -ini_month.day())
        end_month = day.clone().endOf('Month').startOf('Day')
        end = day.clone().endOf('Month').add('days', 7-end_month.day()).startOf('Day')

        while not ini.isSame(end)
            if ini_month.format('MM') == ini.format('MM')
                clase = 'bold'
            else
                clase = ''
            ret.push {value: ini.format('DD'), date: ini.format('YYYY-MM-DD'), clase: clase}
            ini.add('days', 1)
        ret[week*7...week*7+7]


            