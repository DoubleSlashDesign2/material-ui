--[[
    A loosely based Material UI module

    mui-button.lua : This is for creating buttons.

    The MIT License (MIT)

    Copyright (C) 2016 Anedix Technologies, Inc.  All Rights Reserved.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    For other software and binaries included in this module see their licenses.
    The license and the software must remain in full when copying or distributing.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

--]]--

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize: 
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createRRectButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    local nw = options.width + M.getScaleVal(20) --(options.width * 0.05)
    local nh = options.height + M.getScaleVal(20) -- (options.height * 0.05)

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "RRectButton"
    muiData.widgetDict[options.name]["container"] = display.newContainer( nw, nh )
    muiData.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["container"] )
    end

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local nr = radius + M.getScaleVal(8) -- (options.height+M.getScaleVal(8)) * 0.2

    -- paint normal or use gradient?
    local paint = nil
    if options.gradientShadowColor1 ~= nil and options.gradientShadowColor2 ~= nil then
        if options.gradientDirection == nil then
            options.gradientDirection = "up"
        end
        paint = {
            type = "gradient",
            color1 = options.gradientShadowColor1,
            color2 = options.gradientShadowColor2,
            direction = options.gradientDirection
        }
    end

    muiData.widgetDict[options.name]["rrect2"] = display.newRoundedRect( 0, 1, options.width+M.getScaleVal(8), options.height+M.getScaleVal(8), nr )
    if paint ~= nil then
        muiData.widgetDict[options.name]["rrect2"].fill = paint
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect2"] )

    local fillColor = { 0, 0.82, 1 }
    if options.fillColor ~= nil then
        fillColor = options.fillColor
    end

    if options.strokeWidth == nil then
        options.strokeWidth = 0
    end

    if options.strokeColor == nil then
        options.strokeColor = { 0.9, 0.9, 0.9, 1 }
    end

    muiData.widgetDict[options.name]["rrect"] = display.newRoundedRect( 0, 0, options.width, options.height, radius )
    if options.strokeWidth > 0 then
        muiData.widgetDict[options.name]["rrect"].strokeWidth = 1
        muiData.widgetDict[options.name]["rrect"]:setStrokeColor( unpack(options.setStrokeColor) )
    end
    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )
    muiData.widgetDict[options.name]["rrect"].dialogName = options.dialogName

    local rrect = muiData.widgetDict[options.name]["rrect"]

    local fontSize = 10
    local textMargin = options.height * 0.4
    if options.textMargin ~= nil and options.textMargin > 0 then
        textMargin = options.textMargin
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    muiData.widgetDict[options.name]["clickAnimation"] = options.clickAnimation

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    textToMeasure:removeSelf()
    textToMeasure = nil

    muiData.widgetDict[options.name]["myText"] = display.newText( options.text, 0, 0, font, fontSize )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], true )

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, radius )
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    local maxWidth = muiData.widgetDict[options.name]["rrect"].path.width - (radius * 2)
    local scaleFactor = (maxWidth / radius) * 0.5 -- (since this is a radius of circle)

    function rrect:touch (event)
        if muiData.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            --event.target:takeFocus(event)
            -- if scrollView then use the below
            muiData.interceptEventHandler = rrect
            M.updateUI(event)
            if muiData.touching == false then
                muiData.touching = true
                if options.clickAnimation ~= nil then
                    if options.clickAnimation["backgroundColor"] ~= nil then
                        options.clickAnimation["fillColor"] = options.clickAnimation["backgroundColor"]
                    end
                    if options.clickAnimation["fillColor"] ~= nil then
                        muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.clickAnimation["fillColor"]) )
                    end
                end
                if options.touchpoint ~= nil and options.touchpoint == true then
                    muiData.widgetDict[options.name]["myCircle"].x = event.x - muiData.widgetDict[options.name]["container"].x
                    muiData.widgetDict[options.name]["myCircle"].y = event.y - muiData.widgetDict[options.name]["container"].y
                end
                muiData.widgetDict[options.name]["myCircle"].isVisible = true
                muiData.widgetDict[options.name].myCircleTrans = transition.to( muiData.widgetDict[options.name]["myCircle"], { time=500,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(muiData.widgetDict[options.name]["container"],{time=300, xScale=1.02, yScale=1.02, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "moved" ) then
            if options.fillColor ~= nil then
                muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                  event.phase = "offTarget"
                  -- print("Its out of the button area")
                  -- event.target:dispatchEvent(event)
            else
                event.phase = "onTarget"
                if muiData.interceptMoved == false then
                    if options.clickAnimation ~= nil then
                        if options.clickAnimation["time"] == nil then
                            options.clickAnimation["time"] = 400
                        end
                        transition.fadeOut(muiData.widgetDict[options.name]["rrect"],{time=options.clickAnimation["time"]})
                    end
                    event.target = muiData.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])

                    assert( options.callBack )(event)
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
    end
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", muiData.widgetDict[options.name]["rrect"] )
end

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize: 
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createRectButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "RectButton"
    muiData.widgetDict[options.name]["container"] = display.newContainer( options.width+4, options.height+4 )
    muiData.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["container"] )
    end

    -- paint normal or use gradient?
    local paint = nil
    if options.gradientColor1 ~= nil and options.gradientColor2 ~= nil then
        if options.gradientDirection == nil then
            options.gradientDirection = "up"
        end
        paint = {
            type = "gradient",
            color1 = options.gradientColor1,
            color2 = options.gradientColor2,
            direction = options.gradientDirection
        }
    end

    local fillColor = { 0, 0.82, 1 }
    if options.fillColor ~= nil then
        fillColor = options.fillColor
    end

    local strokeWidth = 0
    if paint ~= nil then strokeWidth = 1 end

    muiData.widgetDict[options.name]["rrect"] = display.newRect( 0, 0, options.width, options.height )
    if paint ~= nil then
        muiData.widgetDict[options.name]["rrect"].fill = paint
    end
    muiData.widgetDict[options.name]["rrect"].strokeWidth = strokeWidth
    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )

    local rrect = muiData.widgetDict[options.name]["rrect"]

    local fontSize = 10
    local textMargin = options.height * 0.4
    if options.textMargin ~= nil and options.textMargin > 0 then
        textMargin = options.textMargin
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    textToMeasure:removeSelf()
    textToMeasure = nil

    muiData.widgetDict[options.name]["myText"] = display.newText( options.text, 0, 0, font, fontSize )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], true )

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    local radius = options.height * 0.1
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, radius )
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    local maxWidth = (muiData.widgetDict[options.name]["rrect"].path.width * 2) - (radius * 2)
    local scaleFactor = (maxWidth / radius) * 0.5 -- (since this is a radius of circle)

    function rrect:touch (event)
        if muiData.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            muiData.interceptEventHandler = rrect
            M.updateUI(event)
            if muiData.touching == false then
                muiData.touching = true
                if options.clickAnimation ~= nil then
                    if options.clickAnimation["backgroundColor"] ~= nil then
                        options.clickAnimation["fillColor"] = options.clickAnimation["backgroundColor"]
                    end
                    if options.clickAnimation["fillColor"] ~= nil then
                        muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.clickAnimation["fillColor"]) )
                    end
                end
                if options.touchpoint ~= nil and options.touchpoint == true then
                    muiData.widgetDict[options.name]["myCircle"].x = event.x - muiData.widgetDict[options.name]["container"].x
                    muiData.widgetDict[options.name]["myCircle"].y = event.y - muiData.widgetDict[options.name]["container"].y
                end
                muiData.widgetDict[options.name]["myCircle"].isVisible = true
                muiData.widgetDict[options.name].myCircleTrans = transition.to( muiData.widgetDict[options.name]["myCircle"], { time=500,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(muiData.widgetDict[options.name]["container"],{time=500, xScale=1.02, yScale=1.02, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "moved" ) then
            if options.fillColor ~= nil then
                muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- print("Its out of the button area")
                -- event.target:dispatchEvent(event)
            else
              event.phase = "onTarget"
                if muiData.interceptMoved == false then
                    if options.clickAnimation ~= nil then
                        if options.clickAnimation["time"] == nil then
                            options.clickAnimation["time"] = 400
                        end
                        transition.fadeOut(muiData.widgetDict[options.name]["rrect"],{time=options.clickAnimation["time"]})
                    end
                    event.target = muiData.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])

                    assert( options.callBack )(event)
                end
                muiData.interceptEventHandler = nil
                muiData.interceptMoved = false
                muiData.touching = false
            end
        end
    end
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", muiData.widgetDict[options.name]["rrect"] )
end


--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize: 
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createIconButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "IconButton"
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = x
    muiData.widgetDict[options.name]["mygroup"].y = y
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height * (0.2 * M.getSizeRatio())
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local fontSize = options.height
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end
    fontSize = mathFloor(tonumber(fontSize))

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local textColor = { 0, 0.82, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local checkbox = {contentHeight=options.height, contentWidth=options.width}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight )
    local tw = textToMeasure.contentWidth
    local th = textToMeasure.contentHeight

    textToMeasure:removeSelf()
    textToMeasure = nil

    local options2 = 
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        font = font,
        width = tw,
        fontSize = fontSize,
        align = "center"
    }

    muiData.widgetDict[options.name]["myText"] = display.newText( options2 )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["myText"].isVisible = true
    if isChecked then
        muiData.widgetDict[options.name]["myText"].isChecked = isChecked
    end
    muiData.widgetDict[options.name]["value"] = isChecked

    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myText"], true )

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( 0, 0, radius )
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )

    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].x = 0
    muiData.widgetDict[options.name]["myCircle"].y = 0
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    checkbox = muiData.widgetDict[options.name]["myText"]

    local radiusOffset = 2.5
    if muiData.masterRatio > 1 then radiusOffset = 2.0 end
    local maxWidth = checkbox.contentWidth - (radius * radiusOffset)
    local scaleFactor = ((maxWidth * (1.3 * muiData.masterRatio)) / radius) -- (since this is a radius of circle)

    function checkbox:touch (event)
        if muiData.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            muiData.interceptEventHandler = checkbox
            M.updateUI(event)
            if muiData.touching == false then
                muiData.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true then
                    muiData.widgetDict[options.name]["myCircle"].x = event.x - muiData.widgetDict[options.name]["mygroup"].x
                    muiData.widgetDict[options.name]["myCircle"].y = event.y - muiData.widgetDict[options.name]["mygroup"].y
                end
                muiData.widgetDict[options.name]["myCircle"].isVisible = true
                muiData.widgetDict[options.name].myCircleTrans = transition.to( muiData.widgetDict[options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(checkbox,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- event.target:dispatchEvent(event)
                -- print("Its out of the button area")
            else
              event.phase = "onTarget"
                if muiData.interceptMoved == false then
                    event.target = muiData.widgetDict[options.name]["checkbox"]
                    event.altTarget = muiData.widgetDict[options.name]["myText"]
                    event.myTargetName = options.name
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["myText"])

                    assert( options.callBack )(event)
                end
                muiData.interceptEventHandler = nil
                muiData.interceptMoved = false
                muiData.touching = false
            end
        end
    end
    muiData.widgetDict[options.name]["myText"]:addEventListener( "touch", muiData.widgetDict[options.name]["myText"] )
end

function M.createCheckBox(options)
    M.createIconButton({
        name = options.name,
        text = "check_box_outline_blank",
        width = options.width,
        height = options.height,
        x = options.x,
        y = options.y,
        font = "MaterialIcons-Regular.ttf",
        textColor = options.textColor,
        textAlign = "center",
        callBack = M.actionForCheckbox
    })
end

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize: 
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createRadioButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    muiData.widgetDict[options.basename]["radio"][options.name] = {}
    muiData.widgetDict[options.basename]["type"] = "RadioButton"

    local radioButton =  muiData.widgetDict[options.basename]["radio"][options.name]
    radioButton["mygroup"] = display.newGroup()
    radioButton["mygroup"].x = x
    radioButton["mygroup"].y = y
    radioButton["touching"] = false

    if options.scrollView ~= nil and muiData.widgetDict[options.name]["scrollView"] == nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local fontSize = options.height
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end
    fontSize = mathFloor(tonumber(fontSize))

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local textColor = { 0, 0.82, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    local labelFont = native.systemFont
    if options.labelFont ~= nil then
        labelFont = options.labelFont
    end

    local label = "???"
    if options.label ~= nil then
        label = options.label
    end

    local labelColor = { 0, 0, 0 }
    if options.labelColor ~= nil then
        labelColor = options.labelColor
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    radioButton["font"] = font
    radioButton["fontSize"] = fontSize
    radioButton["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local checkbox = {contentHeight=options.height, contentWidth=options.width}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    local textWidth = textToMeasure.contentWidth
    local textHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

    local options2 = 
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        font = font,
        width = textWidth,
        fontSize = fontSize,
        align = "center"
    }

    radioButton["myText"] = display.newText( options2 )
    radioButton["myText"]:setFillColor( unpack(textColor) )
    radioButton["myText"].isVisible = true
    if isChecked then
        if options.textOn ~= nil then
            radioButton["myText"].text = options.textOn
        end
        radioButton["myText"].isChecked = isChecked
    end
    radioButton["myText"].value = options.value
    radioButton["mygroup"]:insert( radioButton["myText"], true )

    -- add the label

    local textToMeasure2 = display.newText( options.label, 0, 0, options.labelFont, fontSize )
    local labelWidth = textToMeasure2.contentWidth
    textToMeasure2:removeSelf()
    textToMeasure2 = nil

    local labelX = radioButton["mygroup"].x
    -- x,y of both myText and label is centered so divide by half
    local labelSpacing = fontSize * 0.1
    labelX = radioButton["myText"].x + (textWidth * 0.5) + labelSpacing    
    labelX = labelX + (labelWidth * 0.5)
    local options3 = 
    {
        --parent = muiData.widgetDict[options.name]["mygroup"],
        text = options.label,
        x = mathFloor(labelX),
        y = 0,
        width = labelWidth,
        font = labelFont,
        fontSize = fontSize
    }

    radioButton["myLabel"] = display.newText( options3 )
    radioButton["myLabel"]:setFillColor( unpack(labelColor) )
    radioButton["myLabel"]:setStrokeColor( 0 )
    radioButton["myLabel"].strokeWidth = 3
    radioButton["myLabel"].isVisible = true
    radioButton["mygroup"]:insert( radioButton["myLabel"], false )

    -- add the animated circle

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    radioButton["myCircle"] = display.newCircle( options.height, options.height, radius )
    radioButton["myCircle"]:setFillColor( unpack(circleColor) )
    radioButton["myCircle"].isVisible = false
    radioButton["myCircle"].x = 0
    radioButton["myCircle"].y = 0
    radioButton["myCircle"].alpha = 0.3
    radioButton["mygroup"]:insert( radioButton["myCircle"], true ) -- insert and center bkgd

    local maxWidth = checkbox.contentWidth - (radius * 2.5)
    local scaleFactor = ((maxWidth * 1.3) / radius) -- (since this is a radius of circle)

    checkbox = radioButton["myText"]

    function checkbox:touch (event)
        if muiData.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            muiData.interceptEventHandler = checkbox
            M.updateUI(event)
            if muiData.touching == false then
                muiData.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true then
                    muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                    muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
                end
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].isVisible = true
                muiData.widgetDict[options.basename]["radio"][options.name].myCircleTrans = transition.to( muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(checkbox,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- event.target:dispatchEvent(event)
                -- print("Its out of the button area")
            else
              event.phase = "onTarget"
                if muiData.interceptMoved == false then
                    --event.target = muiData.widgetDict[options.name]["rrect"]
                    event.myTargetName = options.name
                    event.myTargetBasename = options.basename
                    event.altTarget = muiData.widgetDict[options.basename]["radio"][options.name]["myText"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["radio"][options.name]["myText"])

                    assert( options.callBack )(event)
                end
                muiData.interceptEventHandler = nil
                muiData.interceptMoved = false
                muiData.touching = false
            end
        end
    end
    muiData.widgetDict[options.basename]["radio"][options.name]["myText"]:addEventListener( "touch", muiData.widgetDict[options.basename]["radio"][options.name]["myText"] )

end


function M.createRadioGroup(options)

    local x, y = options.x, options.y

    if options.isChecked == nil then
        options.isChecked = false
    end

    if options.spacing == nil then
        options.spacing = 10
    end

    if options.list ~= nil then
        local count = 0
        muiData.widgetDict[options.name] = {}
        muiData.widgetDict[options.name]["radio"] = {}
        muiData.widgetDict[options.name]["type"] = "RadioGroup"
        for i, v in ipairs(options.list) do            
            M.createRadioButton({
                name = options.name .. "_" .. i,
                basename = options.name,
                label = v.key,
                value = v.value,
                text = "radio_button_unchecked",
                textOn = "radio_button_checked",
                width = options.width,
                height = options.height,
                x = x,
                y = y,
                isChecked = v.isChecked,
                font = "MaterialIcons-Regular.ttf",
                labelFont = options.labelFont,
                textColor = { 1, 0, 0.4 },
                textAlign = "center",
                labelColor = options.labelColor,
                callBack = options.callBack
            })
            local radioButton = muiData.widgetDict[options.name]["radio"][options.name.."_"..i]
            if options.layout ~= nil and options.layout == "horizontal" then
                width = radioButton["myText"].contentWidth + radioButton["myLabel"].contentWidth + options.spacing
                x = x + width + (radioButton["myText"].contentWidth * 0.2)
            else
                y = y + radioButton["myText"].contentHeight + options.spacing
            end
            count = count + 1
        end
    end

end

function M.actionForPlus( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = "add_circle"
         else
            muiTarget.isChecked = true
            muiTarget.text = "add_circle"
            if muiTargetValue ~= nil then
                print("checkbox value = "..muiTargetValue)
            end
        end
    end
end

function M.actionForCheckbox( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = "check_box_outline_blank"
         else
            muiTarget.isChecked = true
            muiTarget.text = "check_box"
            if muiTargetValue ~= nil then
                print("checkbox value = "..muiTargetValue)
            end
        end
    end
end

function M.actionForRadioButton( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        -- uncheck all then check the one that is checked
        local basename = M.getEventParameter(e, "basename")
        local foundName = false

        local list = muiData.widgetDict[basename]["radio"]
        for k, v in pairs(list) do
            v["myText"].isChecked = false
            v["myText"].text = "radio_button_unchecked"
        end

        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = "radio_button_unchecked"
         else
            muiTarget.isChecked = true
            muiTarget.text = "radio_button_checked"
        end
        if muiTargetValue ~= nil then
            print("radio button value = "..muiTargetValue)
        end
    end
end

function M.actionForButton( e )
    print("button action!")
end

return M
