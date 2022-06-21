local obs = obslua;

local scene_name_to_move = nil

local bounds_type = obs.OBS_BOUNDS_SCALE_INNER

local bounds_alignment = 0

local screenHeight = 1080

local screenWidth = 1920

local gap = 0

local aspectRatioW = 16

local aspectRatioH = 9

local aspectRatio = aspectRatioW/aspectRatioH

function script_description()
    
  return [[Script that sets de position and scale of all sources in a scene automaticly, 
    simulating a galery view , like in zoom metting. 
    The grid changes automaticly when a source is added, the order or visibility changes]]
end

function script_properties()
  local props = obs.obs_properties_create()
  obs.obs_properties_add_text(props, "scene_name_to_move", "SCENE", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_int(props,"gap", "GAP",0,100,1)
  
  obs.obs_properties_add_float(props,"aspectRatioW", "SOURCE RATIO WIDTH",1,16,0.01)
  obs.obs_properties_add_float(props,"aspectRatioH", "SOURCE RATIO HEIGHT",1,9,0.01)

  local bounds_type_list =  obs.obs_properties_add_list(props, "bounds_type", "BOUNS TYPE", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)


  obs.obs_property_list_add_string(bounds_type_list, "SCALE INNER"    ,"OBS_BOUNDS_SCALE_INNER")
  obs.obs_property_list_add_string(bounds_type_list, "SCALE OUTER"    ,"OBS_BOUNDS_SCALE_OUTER")
  obs.obs_property_list_add_string(bounds_type_list, "SCALE TO WIDTH" ,"OBS_BOUNDS_SCALE_TO_WIDTH")
  obs.obs_property_list_add_string(bounds_type_list, "SCALE TO HEIGHT","OBS_BOUNDS_SCALE_TO_HEIGHT")
  obs.obs_property_list_add_string(bounds_type_list, "STRETCH"        ,"OBS_BOUNDS_STRETCH")
  obs.obs_property_list_add_string(bounds_type_list, "MAX ONLY"       ,"OBS_BOUNDS_MAX_ONLY")

  local bounds_alignment_list =  obs.obs_properties_add_list(props, "bounds_alignment", "BOUNDS ALIGNMENT", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING )
  
  obs.obs_property_list_add_string(bounds_alignment_list, "TOP_LEFT"     ,"TOP_LEFT"     )
  obs.obs_property_list_add_string(bounds_alignment_list, "CENTER"       ,"CENTER"       )
  obs.obs_property_list_add_string(bounds_alignment_list, "TOP_CENTER"   ,"TOP_CENTER"   )
  obs.obs_property_list_add_string(bounds_alignment_list, "TOP_RIGHT"    ,"TOP_RIGHT"    )
  obs.obs_property_list_add_string(bounds_alignment_list, "CENTER_LEFT"  ,"CENTER_LEFT"  )
  obs.obs_property_list_add_string(bounds_alignment_list, "CENTER_RIGHT" ,"CENTER_RIGHT" )
  obs.obs_property_list_add_string(bounds_alignment_list, "BOTTOM_LEFT"  ,"BOTTOM_LEFT"  )
  obs.obs_property_list_add_string(bounds_alignment_list, "BOTTOM_CENTER","BOTTOM_CENTER")
  obs.obs_property_list_add_string(bounds_alignment_list, "BOTTOM_RIGHT" ,"BOTTOM_RIGHT" )

  obs.obs_properties_add_button(props, 'button', 'UPDATE', btnEvent)

  return props
end

 function script_defaults(settings)

  obs.obs_data_set_default_int(settings, 'gap', gap)

  obs.obs_data_set_autoselect_string(settings,"bounds_type" ,"OBS_BOUNDS_SCALE_INNER")
  obs.obs_data_set_autoselect_string(settings,"bounds_alignment" ,"CENTER")

  obs.obs_data_set_default_int(settings, 'aspectRatioW', aspectRatioW)
  obs.obs_data_set_default_int(settings, 'aspectRatioH', aspectRatioH)
  obs.obs_data_set_default_int(settings, 'aspectRatio', aspectRatio)

end

 function btnEvent()
  move_all()
end

 function get_bounds_type(name)
  
  local result

  if      name == "OBS_BOUNDS_STRETCH"          then  result =  obs.OBS_BOUNDS_STRETCH
  elseif  name == "OBS_BOUNDS_SCALE_INNER"      then  result =  obs.OBS_BOUNDS_SCALE_INNER
  elseif  name == "OBS_BOUNDS_SCALE_OUTER"      then  result =  obs.OBS_BOUNDS_SCALE_OUTER
  elseif  name == "OBS_BOUNDS_SCALE_TO_WIDTH"   then  result =  obs.OBS_BOUNDS_SCALE_TO_WIDTH
  elseif  name == "OBS_BOUNDS_SCALE_TO_HEIGHT"  then  result =  obs.OBS_BOUNDS_SCALE_TO_HEIGHT
  elseif  name == "OBS_BOUNDS_MAX_ONLY"         then  result =  obs.OBS_BOUNDS_MAX_ONLY
  else                                                result =  obs.OBS_BOUNDS_SCALE_INNER
  end  

  return result
end

function get_bounds_alignment(name)
  
  local result

  if      name == "TOP_LEFT"      then  result =  5
  elseif  name == "TOP_CENTER"    then  result =  4
  elseif  name == "TOP_RIGHT"     then  result =  6
  elseif  name == "CENTER_LEFT"   then  result =  1
  elseif  name == "CENTER"        then  result =  0
  elseif  name == "CENTER_RIGHT"  then  result =  2
  elseif  name == "BOTTOM_LEFT"   then  result =  9
  elseif  name == "BOTTOM_CENTER" then  result =  8
  elseif  name == "BOTTOM_RIGHT"  then  result =  10
  else                                  result =  0
  end  
  return result
end

function move_source(sceneitem, VideoFormat)

    if sceneitem then

    obs.obs_sceneitem_set_bounds_type(sceneitem, bounds_type) 
    obs.obs_sceneitem_set_bounds_alignment(sceneitem, bounds_alignment)

    obs.obs_sceneitem_set_bounds(sceneitem, VideoFormat.scale)-- Sets the bounding box width/height of the scene item. -- in this case the grid spot size

    obs.obs_sceneitem_set_alignment(sceneitem, 0) -- OBS_ALIGN_CENTER -- Base to calculate the positions
    obs.obs_sceneitem_set_pos(sceneitem, VideoFormat.position)  
    end

end

function calculateLayout(VisibleVideoCount)
  
  local bestLayout = {
    area= 0,
    cols= 0,
    rows= 0,
    width= 0,
    height= 0
  };

  for cols = 1, VisibleVideoCount, 1 do
    local rows = math.ceil(VisibleVideoCount / cols);
    local hScale = screenWidth / (cols * aspectRatio);
    local vScale = screenHeight / rows;
    local width;
    local height;
  
    if (hScale <= vScale) then
      width = math.floor(screenWidth / cols);
      height = math.floor(width / aspectRatio);
    else
      height = math.floor(screenHeight / rows);
      width = math.floor(height * aspectRatio);
    end

    local area = width * height;

    if area >= bestLayout.area then
      bestLayout = {
        area= area,
        cols= cols,
        rows= rows,
        width= width,
        height= height
      };
    end

  end --[for]--
  return bestLayout
end

-- ↓ refactor this function ↓
function getQtdItensNaLinha(naoAlocado, cols)

    if naoAlocado>cols then 
      return cols 
    else 
      return naoAlocado
    end
  end



  function getX(indexDoItemNaLinhaAtual, videoWidth, screenWidth, qtdItensNaLinha, gap)
  local x = ( videoWidth * indexDoItemNaLinhaAtual) + (videoWidth/2) + ((screenWidth - (videoWidth * qtdItensNaLinha))/2)

  local termoCentralCols = (1 + qtdItensNaLinha)/2
  local CalcGap = math.abs(termoCentralCols - (indexDoItemNaLinhaAtual+1))*gap

  if x == screenWidth/2 then
    return x
  end

  if x < screenWidth/2 then
      x = x - CalcGap
    else
      x = x + CalcGap
    end

    return x
end
-- ↓ refactor this function ↓
function getY(indexDaLinha, videoHeight, screenHeight, rowsCount, gap)
 
  local y = ( videoHeight * indexDaLinha) + (videoHeight/2) + ((screenHeight - (videoHeight * rowsCount))/2)

  local termoCentralRows = (1 + rowsCount)/2
  local CalcGap = math.abs(termoCentralRows - (indexDaLinha+1)) * gap

  if y == screenHeight/2 then
    return y
  end
  if y < screenHeight/2 then
    y = y-CalcGap
  else
    y = y+CalcGap
  end

  return y
end
-- ↓ refactor this function ↓
function getVideoFormatArray(VisibleVideoCount, rowsCount, colsCount, videoWidth, videoHeight)

  local naoAlocado = VisibleVideoCount;
  local qtdItensNaLinha = colsCount;

  local result = {}

  local CalcHeight = videoHeight - gap
  local CalcWidth = videoWidth - gap*aspectRatio

  local scl = obs.vec2()
  scl.x = CalcWidth
  scl.y = CalcHeight

  for linha = 0, rowsCount-1, 1 do
      
      qtdItensNaLinha = getQtdItensNaLinha(naoAlocado, colsCount)
     

      for  coluna = 0, qtdItensNaLinha-1, 1 do
    
        local pos = obs.vec2()
        pos.x = getX(coluna,CalcWidth,screenWidth,qtdItensNaLinha,gap)
        pos.y = getY(linha,CalcHeight,screenHeight,rowsCount,gap)

        table.insert(result,1,
            {
                position=pos,
                scale=scl
            }
        )

        naoAlocado = naoAlocado-1
      end 
    end

  return result
end

 function move_all()
  
    local scene_as_source = obs.obs_get_source_by_name(scene_name_to_move)
    local scene = obs.obs_scene_from_source(scene_as_source)
    local sceneitems = obs.obs_scene_enum_items(scene)
    local visibleSceneItems = {}

    for i, sceneitem in ipairs(sceneitems) do

      local itemVisibility = obs.obs_sceneitem_visible(sceneitem)
      if itemVisibility then
        table.insert(visibleSceneItems,sceneitem)
      end

    end
  

    local visibleItemsCount = #visibleSceneItems;
    local count = #sceneitems;

    local bestLayout = calculateLayout(visibleItemsCount); -->calculate  best leyout
    local VideoFormat = getVideoFormatArray(visibleItemsCount,bestLayout.rows,bestLayout.cols,bestLayout.width,bestLayout.height) -->generate source positions array

    for i, VisibleSceneitem in ipairs(visibleSceneItems) do
        move_source(VisibleSceneitem, VideoFormat[i])  --> move one source
    end
    obs.sceneitem_list_release(sceneitems)
    obs.obs_source_release(scene_as_source)
end

function script_update(settings)

  scene_name_to_move = obs.obs_data_get_string(settings, 'scene_name_to_move')

  bounds_type =  get_bounds_type(obs.obs_data_get_string(settings, 'bounds_type'))
  bounds_alignment = get_bounds_alignment(obs.obs_data_get_string(settings, 'bounds_alignment'))

  local scene_to_move_as_source = obs.obs_get_source_by_name(scene_name_to_move)

  local sh = obs.obs_source_get_signal_handler(scene_to_move_as_source);

  obs.signal_handler_disconnect(sh,"item_visible",move_all)
  obs.signal_handler_disconnect(sh,"item_add",move_all)
  obs.signal_handler_disconnect(sh,"reorder",move_all)

  obs.signal_handler_connect(sh,"reorder",move_all)
  obs.signal_handler_connect(sh,"item_add",move_all)
  obs.signal_handler_connect(sh,"item_visible",move_all)

  if scene_to_move_as_source then
    screenWidth = obs.obs_source_get_width(scene_to_move_as_source)
    screenHeight = obs.obs_source_get_height(scene_to_move_as_source)
  end

  obs.obs_source_release(scene_to_move_as_source)

  gap  = obs.obs_data_get_int(settings, "gap");

  aspectRatioW = obs.obs_data_get_int(settings, "aspectRatioW");
  aspectRatioH = obs.obs_data_get_int(settings, "aspectRatioH");

  aspectRatio = aspectRatioW/aspectRatioH

end
