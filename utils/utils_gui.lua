local M = {}

function M.get_touched_by_node(node, action)
  -- single touch
  if not action.touch then
    local picked = gui.pick_node(node, action.x, action.y)
    if not picked and action.released then
      picked = true
    end

    if picked then
      action.id = "single_touch"
      return action
    end

    return nil
  end
  
  -- multiple touches
  for i, touchdata in ipairs(action.touch) do
    local picked = gui.pick_node(node, touchdata.x, touchdata.y)
    if picked then
      return touchdata
    end
  end
end

return M
