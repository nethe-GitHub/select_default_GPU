# select_default_GPU

Download and run the batch file "select_default_GPU.bat".

Follow the instructions and choose your desired GPU.

New bat files will be created. They can be ran directly, or called in other automated procedures.

### Example:

![example](/examples/eg1.png)

(Forgive that my system language is Chinese.)

In this example, running *select_GL_C.bat* failed due to lack of admin privilege.

### Notes:

The generated bat files' name end with the first letter of the GPU description.

The OpenGL batches operate some system registry values, thus Administrator privilege is required.

This OpenGL method requires reboot at first use. Only after that the system will seek ICD in the proposed "fallback" way.

*OpenCL™ and OpenGL® Compatibility Pack*(GLOn12) has higher priority in system opengl32.dll logic, this tweak won't work if that's installed.

### Known issues:

Cannot load OpenGL ICD of Intel Processor Graphics in this way.


# 选择默认GPU

下载并运行“选择默认GPU.bat”，按照指示选择要使用的GPU，将会生成对应的批处理文件。

### 例：

![例](/examples/eg2.png)

在这个例子中，由于没有管理员权限，*select_GL_R.bat*运行失败。

### 注：

生成的bat文件名以显卡描述字符串的首字母结尾

OpenGL的脚本涉及一些系统注册表项的操作，所以需要管理员权限

首次用本方法修改OpenGL需要重启，此后系统才能按照这里给出的“备选方案”寻找ICD

在系统的opengl32.dll中会优先选择*OpenCL™和OpenGL®兼容包*（GLOn12），需要将其卸载才能生效

### 罔：

用这种方法不能加载 Intel 核显的 OpenGL ICD。
