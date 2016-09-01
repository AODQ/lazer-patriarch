# LUDUMDARE36
<url="http://ludumdare.com/compo/ludum-dare-36/?action=preview&uid=14310">The Ludum Dare release is located here<url>
If for some reason you want to compile this, you'll have to install DUB and DMD. Also you'll have to perform the following command:

cd derelict/derelict-util-2.0.6
dub add-local derelict-util
cd derelict-util
dub build -brelease

Why? I made changes to the util (it now ignores any functions from a DLL it could not properly load).
