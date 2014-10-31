local transform = require "mjolnir.sk.transform.internal"

function transform:setframe(win, frame, time)
	time = time or 0.2

	transform.transform(
		win,
		{ x = frame.x, y = frame.y },
		{ w = frame.w, h = frame.h },
		time
	)
end

return transform
