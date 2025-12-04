extends StaticBody3D

func obter_posicao_sentar():
	# Ajuste o caminho conforme sua estrutura ("../../sitting_point" ou "$sitting_point")
	return get_node("../../sitting_point").global_transform
