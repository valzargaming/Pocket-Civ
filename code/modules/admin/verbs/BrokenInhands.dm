/proc/getbrokeninhands()
	var/text
	for(var/A in typesof(/obj/item))
		var/obj/item/I = new A(locate(1,1,1) )
		if(!I)
			continue
		var/icon/IL = new(I.lefthand_file)
		var/list/Lstates = IL.IconStates()
		var/icon/IR = new(I.righthand_file)
		var/list/Rstates = IR.IconStates()
		var/icon/J = new(I.icon)
		var/list/istates = J.IconStates()
		if(!Lstates.Find(I.icon_state) && !Lstates.Find(I.inhand_icon_state))
			if(I.icon_state)
				text += "[I.type] WANTS IN LEFT HAND CALLED\n\"[I.icon_state]\".\n"
		if(!Rstates.Find(I.icon_state) && !Rstates.Find(I.inhand_icon_state))
			if(I.icon_state)
				text += "[I.type] WANTS IN RIGHT HAND CALLED\n\"[I.icon_state]\".\n"


		if(I.icon_state)
			if(!istates.Find(I.icon_state))
				text += "[I.type] MISSING NIRMAL ICON CALLED\n\"[I.icon_state]\" IN \"[I.icon]\"\n"
		if(I.inhand_icon_state)
			if(!istates.Find(I.inhand_icon_state))
				text += "[I.type] MISSING NIRMAL ICON CALLED\n\"[I.inhand_icon_state]\" IN \"[I.icon]\"\n"
		text+="\n"
		qdel(I)
	if(text)
		var/F = file("broken_icons.txt")
		fdel(F)
		WRITE_FILE(F, text)
		to_chat(world, "Completely successfully and written to [F]", confidential = TRUE)


