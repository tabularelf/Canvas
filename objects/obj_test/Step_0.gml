if (keyboard_check_released(vk_space)) {
	surf.cache();	
	show_debug_message(surf.getBufferID());
}