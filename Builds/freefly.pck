GDPC                                                                               <   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex0      �      &�y���ڞu;>��.p   res://Camera.gd.remap   �!      !       ��g,;��=�U���   res://Camera.gdcp      &      bq�o�/ҷ���$�I   res://FreeFlyCamera.gd.remap�!      (       �� ���������   res://FreeFlyCamera.gdc �
      Y      �*�SRPƔ&w�@Z�N   res://ThoughtSpace.tscn              ��GdYn��2���z�,   res://addons/godot-git-plugin/git_api.gdnlib       I      ]H7����!Pw,   res://addons/godot-git-plugin/git_api.gdns  p            ����.�YL����   res://default_env.tres  �      �       um�`�N��<*ỳ�8   res://icon.png   "      �      G1?��z�c��vN��   res://icon.png.import         �      ��fe��6�B��^ U�   res://project.binary/      o      9���O���,�j\�|\            GDSC      	   :   �      �����׶�   �����Ķ�   ���������¶�   ����������������򶶶   �����϶�   ����������������¶��   �������������������ض���   �������ض���   �������ض���   �����������ض���   ζ��   ����������������������ض   �����¶�   ����¶��   ��������������������ض��   �����������ض���   �������Ӷ���   ϶��   ����������Ӷ   ����¶��   �������������Ӷ�   ��������������������   ����������Ӷ   ������������������   �                   {   
	Returns a new Vector3 which contains only the x direction
	We'll use this vector to compute the final 3D rotation later
	          {   
	Returns a new Vector3 which contains only the y direction
	We'll use this vector to compute the final 3D rotation later
	        
	First person camera controls
	       
	Hide the mouse when we start
	       
	Show the mouse when we leave
	                                                    	      
                )      *      +      =      >      ?      @      A      B      V      W      Z      [      d      e      f       v   !   w   "   ~   #      %   �   &   �   '   �   (   �   )   �   *   �   +   �   ,   �   -   �   .   �   /   �   0   �   1   �   2   �   3   �   4   �   5   �   6   �   7   �   9   �   :   �   ;   �   <   �   =   �   ?   �   @   �   A   3YY5;�  �  PQYYY:�  YY0�  PQV�  �  �  P�  QYY0�  P�  �  QV�  �  �  ;�  T�	  PQ�  P�  R�  R�  QY�  �  �  �  �  �  T�
  �5  P�  T�
  RZ�  RZ�  QY�  .�  YY0�  P�  �  QV�  �  �  .�  T�	  PQ�  P�  R�  R�  QYY0�  P�  QV�  �  �  �  �  &�  4�  V�  .Y�  �  �  �  �  �  T�  P�  P�  T�  T�
  �  QQY�  �  �  �  T�  P�  P�  T�  T�  �  QQYY0�  PQV�  �  �  �  T�  P�  T�  QYY0�  PQV�  �  �  �  T�  P�  T�  QY`          GDSC         :   /     ������������϶��   �������϶���   ����������������򶶶   �����׶�   ����������������ݶ��   �����������ض���   ������������۶��   ����Ŷ��   ̶��   ��������������¶   ζ��   �����������ض���   ϶��   �������Ŷ���   �����׶�   ����¶��   ����������������Ҷ��   ���������������Ŷ���   ����������Ķ   �����������������������ƶ���                (   
	Move the camera forward or backwards
	   (   
	Move the camera to the left or right
	      
	Move the camera up or down
	     j   
	Allow the player to move the camera with WASD
	See Project settings -> Input map for keyboard bindings
	        move_forward         	   move_back      	   move_left      
   move_right        move_up    	   move_down                                                             	   '   
   (      )      9      :      C      D      E      U      V      _      `      a      q      r      s      |      }       ~   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (   �   )   �   *   �   +   �   ,   �   -   �   .   �   /   �   0   �   1   �   2   �   3   �   4   �   5      6     7     8     9     :     ;   (  <   *  =   ,  >   -  ?   3YY;�  �  PRRQYY:�  �  YY5;�  W�  YY0�  P�  V�  QV�  �  �  T�  �  PQT�  T�  �  �  YY0�	  P�  V�  QV�  �  �  T�  �  PQT�  T�
  �  �  YY0�  P�  V�  QV�  �  �  T�  �  PQT�  T�  �  �  YYY0�  P�  V�  QV�  �  �  T�  �  PRRQ�  �  &�  T�  P�  QV�  T�  P�  QY�  '�  T�  P�  QV�  T�  P�  QY�  &�  T�  P�	  QV�  T�	  P�  QY�  '�  T�  P�
  QV�  T�	  P�  Q�  �  &�  T�  P�  QV�  T�  P�  Q�  �  '�  T�  P�  QV�  T�  P�  QYY0�  P�  V�  QV�  ;�  �  PRRQ�  �  T�  T�  P�  T�  R�  �  R�  �  PRRQR�  �  �  QYY`       [gd_scene load_steps=5 format=2]

[ext_resource path="res://FreeFlyCamera.gd" type="Script" id=1]
[ext_resource path="res://Camera.gd" type="Script" id=2]

[sub_resource type="SphereShape" id=1]

[sub_resource type="BoxShape" id=2]

[node name="Spatial" type="Spatial"]

[node name="FreeFlyPlayer" type="KinematicBody" parent="."]
script = ExtResource( 1 )

[node name="Camera" type="Camera" parent="FreeFlyPlayer"]
script = ExtResource( 2 )

[node name="CollisionShape" type="CollisionShape" parent="FreeFlyPlayer"]
shape = SubResource( 1 )

[node name="Label3D" type="Label3D" parent="."]
transform = Transform( 1.0205, 0, 0, 0, 1.0205, 0, 0, 0, 1.0205, 0, 0, -3.76991 )
pixel_size = 0.1
modulate = Color( 0.0156863, 0.145098, 0.639216, 1 )
text = "test text"

[node name="CSGBox" type="CSGBox" parent="."]
transform = Transform( 4.66226, 0, 0, 0, 0.0767701, 0, 0, 0, 7.29203, 0, -1.86079, 0 )

[node name="Area" type="Area" parent="CSGBox"]

[node name="CollisionShape" type="CollisionShape" parent="CSGBox/Area"]
shape = SubResource( 2 )
              [general]

load_once=true
symbol_prefix="godot_"
reloadable=false
singleton=false

[entry]

OSX.64="res://addons/godot-git-plugin/osx/libgitapi.dylib"
Windows.64="res://addons/godot-git-plugin/win64/libgitapi.dll"
X11.64="res://addons/godot-git-plugin/linux/libgitapi.so"

[dependencies]

OSX.64=[  ]
Windows.64=[  ]
X11.64=[  ]
       [gd_resource type="NativeScript" load_steps=2 format=2]

[ext_resource path="res://addons/godot-git-plugin/git_api.gdnlib" type="GDNativeLibrary" id=1]

[resource]
resource_name = "GitAPI"
class_name = "GitAPI"
library = ExtResource( 1 )
script_class_name = "GitAPI"
     [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDST@   @            �  WEBPRIFF�  WEBPVP8L�  /?����m��������_"�0@��^�"�v��s�}� �W��<f��Yn#I������wO���M`ҋ���N��m:�
��{-�4b7DԧQ��A �B�P��*B��v��
Q�-����^R�D���!(����T�B�*�*���%E["��M�\͆B�@�U$R�l)���{�B���@%P����g*Ųs�TP��a��dD
�6�9�UR�s����1ʲ�X�!�Ha�ߛ�$��N����i�a΁}c Rm��1��Q�c���fdB�5������J˚>>���s1��}����>����Y��?�TEDױ���s���\�T���4D����]ׯ�(aD��Ѓ!�a'\�G(��$+c$�|'�>����/B��c�v��_oH���9(l�fH������8��vV�m�^�|�m۶m�����q���k2�='���:_>��������á����-wӷU�x�˹�fa���������ӭ�M���SƷ7������|��v��v���m�d���ŝ,��L��Y��ݛ�X�\֣� ���{�#3���
�6������t`�
��t�4O��ǎ%����u[B�����O̲H��o߾��$���f���� �H��\��� �kߡ}�~$�f���N\�[�=�'��Nr:a���si����(9Lΰ���=����q-��W��LL%ɩ	��V����R)�=jM����d`�ԙHT�c���'ʦI��DD�R��C׶�&����|t Sw�|WV&�^��bt5WW,v�Ş�qf���+���Jf�t�s�-BG�t�"&�Ɗ����׵�Ջ�KL�2)gD� ���� NEƋ�R;k?.{L�$�y���{'��`��ٟ��i��{z�5��i������c���Z^�
h�+U�mC��b��J��uE�c�����h��}{�����i�'�9r�����ߨ򅿿��hR�Mt�Rb���C�DI��iZ�6i"�DN�3���J�zڷ#oL����Q �W��D@!'��;�� D*�K�J�%"�0�����pZԉO�A��b%�l�#��$A�W�A�*^i�$�%a��rvU5A�ɺ�'a<��&�DQ��r6ƈZC_B)�N�N(�����(z��y�&H�ض^��1Z4*,RQjԫ׶c����yq��4���?�R�����0�6f2Il9j��ZK�4���է�0؍è�ӈ�Uq�3�=[vQ�d$���±eϘA�����R�^��=%:�G�v��)�ǖ/��RcO���z .�ߺ��S&Q����o,X�`�����|��s�<3Z��lns'���vw���Y��>V����G�nuk:��5�U.�v��|����W���Z���4�@U3U�������|�r�?;�
         [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
process/normal_map_invert_y=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
              [remap]

path="res://Camera.gdc"
               [remap]

path="res://FreeFlyCamera.gdc"
        �PNG

   IHDR   @   @   �iq�   sRGB ���  �IDATx��ytTU��?�ի%���@ȞY1JZ �iA�i�[P��e��c;�.`Ow+4�>�(}z�EF�Dm�:�h��IHHB�BR!{%�Zߛ?��	U�T�
���:��]~�������-�	Ì�{q*�h$e-
�)��'�d�b(��.�B�6��J�ĩ=;���Cv�j��E~Z��+��CQ�AA�����;�.�	�^P	���ARkUjQ�b�,#;�8�6��P~,� �0�h%*QzE� �"��T��
�=1p:lX�Pd�Y���(:g����kZx ��A���띊3G�Di� !�6����A҆ @�$JkD�$��/�nYE��< Q���<]V�5O!���>2<��f��8�I��8��f:a�|+�/�l9�DEp�-�t]9)C�o��M~�k��tw�r������w��|r�Ξ�	�S�)^� ��c�eg$�vE17ϟ�(�|���Ѧ*����
����^���uD�̴D����h�����R��O�bv�Y����j^�SN֝
������PP���������Y>����&�P��.3+�$��ݷ�����{n����_5c�99�fbסF&�k�mv���bN�T���F���A�9�
(.�'*"��[��c�{ԛmNު8���3�~V� az
�沵�f�sD��&+[���ke3o>r��������T�]����* ���f�~nX�Ȉ���w+�G���F�,U�� D�Դ0赍�!�B�q�c�(
ܱ��f�yT�:��1�� +����C|��-�T��D�M��\|�K�j��<yJ, ����n��1.FZ�d$I0݀8]��Jn_� ���j~����ցV���������1@M�)`F�BM����^x�>
����`��I�˿��wΛ	����W[�����v��E�����u��~��{R�(����3���������y����C��!��nHe�T�Z�����K�P`ǁF´�nH啝���=>id,�>�GW-糓F������m<P8�{o[D����w�Q��=N}�!+�����-�<{[���������w�u�L�����4�����Uc�s��F�륟��c�g�u�s��N��lu���}ן($D��ת8m�Q�V	l�;��(��ڌ���k�
s\��JDIͦOzp��مh����T���IDI���W�Iǧ�X���g��O��a�\:���>����g���%|����i)	�v��]u.�^�:Gk��i)	>��T@k{'	=�������@a�$zZ�;}�󩀒��T�6�Xq&1aWO�,&L�cřT�4P���g[�
p�2��~;� ��Ҭ�29�xri� ��?��)��_��@s[��^�ܴhnɝ4&'
��NanZ4��^Js[ǘ��2���x?Oܷ�$��3�$r����Q��1@�����~��Y�Qܑ�Hjl(}�v�4vSr�iT�1���f������(���A�ᥕ�$� X,�3'�0s����×ƺk~2~'�[�ё�&F�8{2O�y�n�-`^/FPB�?.�N�AO]]�� �n]β[�SR�kN%;>�k��5������]8������=p����Ցh������`}�
�J�8-��ʺ����� �fl˫[8�?E9q�2&������p��<�r�8x� [^݂��2�X��z�V+7N����V@j�A����hl��/+/'5�3�?;9
�(�Ef'Gyҍ���̣�h4RSS� ����������j�Z��jI��x��dE-y�a�X�/�����:��� +k�� �"˖/���+`��],[��UVV4u��P �˻�AA`��)*ZB\\��9lܸ�]{N��礑]6�Hnnqqq-a��Qxy�7�`=8A�Sm&�Q�����u�0hsPz����yJt�[�>�/ޫ�il�����.��ǳ���9��
_
��<s���wT�S������;F����-{k�����T�Z^���z�!t�۰؝^�^*���؝c
���;��7]h^
��PA��+@��gA*+�K��ˌ�)S�1��(Ե��ǯ�h����õ�M�`��p�cC�T")�z�j�w��V��@��D��N�^M\����m�zY��C�Ҙ�I����N�Ϭ��{�9�)����o���C���h�����ʆ.��׏(�ҫ���@�Tf%yZt���wg�4s�]f�q뗣�ǆi�l�⵲3t��I���O��v;Z�g��l��l��kAJѩU^wj�(��������{���)�9�T���KrE�V!�D���aw���x[�I��tZ�0Y �%E�͹���n�G�P�"5FӨ��M�K�!>R���$�.x����h=gϝ�K&@-F��=}�=�����5���s �CFwa���8��u?_����D#���x:R!5&��_�]���*�O��;�)Ȉ�@�g�����ou�Q�v���J�G�6�P�������7��-���	պ^#�C�S��[]3��1���IY��.Ȉ!6\K�:��?9�Ev��S]�l;��?/� ��5�p�X��f�1�;5�S�ye��Ƅ���,Da�>�� O.�AJL(���pL�C5ij޿hBƾ���ڎ�)s��9$D�p���I��e�,ə�+;?�t��v�p�-��&����	V���x���yuo-G&8->�xt�t������Rv��Y�4ZnT�4P]�HA�4�a�T�ǅ1`u\�,���hZ����S������o翿���{�릨ZRq��Y��fat�[����[z9��4�U�V��Anb$Kg������]������8�M0(WeU�H�\n_��¹�C�F�F�}����8d�N��.��]���u�,%Z�F-���E�'����q�L�\������=H�W'�L{�BP0Z���Y�̞���DE��I�N7���c��S���7�Xm�/`�	�+`����X_��KI��^��F\�aD�����~�+M����ㅤ��	SY��/�.�`���:�9Q�c �38K�j�0Y�D�8����W;ܲ�pTt��6P,� Nǵ��Æ�:(���&�N�/ X��i%�?�_P	�n�F�.^�G�E���鬫>?���"@v�2���A~�aԹ_[P, n��N������_rƢ��    IEND�B`�       ECFG      _global_script_classes�                     class         GitAPI        language      NativeScript      path   *   res://addons/godot-git-plugin/git_api.gdns        base          _global_script_class_icons                GitAPI            application/config/name         ThoughtBubblesV5   application/run/main_scene          res://ThoughtSpace.tscn    application/config/icon         res://icon.png  *   editor/version_control_autoload_on_startup         "   editor/version_control_plugin_name         GitAPI  +   gui/common/drop_mouse_on_gui_input_disabled            input/move_down�              events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   Q      physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            deadzone      ?   input/move_up�              events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   E      physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode          physical_scancode             unicode           echo          script            deadzone      ?   input/move_forward�              events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   W      physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            deadzone      ?   input/move_back�              events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   S      physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            deadzone      ?   input/move_right�              events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   D      physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            deadzone      ?   input/move_left�              events              InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode   A      physical_scancode             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device            alt           shift             control           meta          command           pressed           scancode        physical_scancode             unicode           echo          script            deadzone      ?   mono/project/assembly_name         ThoughtBubblesV5)   physics/common/enable_pause_aware_picking         )   rendering/environment/default_environment          res://default_env.tres   