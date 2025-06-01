### Java环境配置

依赖扩展：
Code Runner
Extension Pack for Java
Hex Editor
Springboot

终端乱码，搜索下面配置修改，`Command Prompt`名字不要修改，有些配置会根据这个命令调用。
```json
    "terminal.integrated.defaultProfile.windows": "PowerShell",
    "terminal.integrated.profiles.windows": {

        "PowerShell": {
            "source": "PowerShell",
            "icon": "terminal-powershell"
        },
        "Command Prompt": {
            "path": [
                "${env:windir}\\Sysnative\\cmd.exe",
                "${env:windir}\\System32\\cmd.exe"
            ],
            "args": [],
            "icon": "terminal-cmd"
        },
        "Conda": {
            "source": "PowerShell",
            "args": [
                "-ExecutionPolicy",
                "ByPass",
                "-NoExit",
                "-Command",
                "& 'C:\\ProgramData\\miniconda3\\shell\\condabin\\conda-hook.ps1'; conda activate 'C:\\ProgramData\\miniconda3' "
            ],
            "title": "Anaconda Prompt"
        }
    },
    "[jsonc]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    }
```
maven乱码，打开 `.vscode/settings.json` 修改：
```json
{
  "java.compile.nullAnalysis.mode": "automatic",
  "maven.view": "hierarchical",
  "java.configuration.updateBuildConfiguration": "interactive",
  "maven.terminal.customEnv": [
    {
      "environmentVariable": "MAVEN_OPTS",
      "value": "-Xmx512m -Xms256m -Dfile.encoding=UTF-8"
    }
  ]
}
```
mavne打包跳过test：
```xml
<properties>
    <maven.test.skip>true</maven.test.skip>
</properties>
```
或
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.0.0-M1</version>
    <configuration>
        <skipTests>true</skipTests>
    </configuration>
</plugin>
```


运行时，点击右上角 Run Code --> Debugger Java


### C环境配置
```json
// .vscode/c_cpp_properties.json
{
  "configurations": [
    {
      "name": "WSL",
      "includePath": [
        "${workspaceFolder}/**",
        "${workspaceFolder}/ngx_http_cennavi_common/**",
        "${workspaceFolder}/ngx_http_encrypt_module/**",
        "${workspaceFolder}/ngx_http_license_module/**",
        "${workspaceFolder}/ngx_http_mapurl_module/**",
        "${workspaceFolder}/ngx_http_mapzrcurl_module/**",
      ],
      "defines": ["NGX_HTTP_MODULE"],
      "compilerPath": "/usr/bin/gcc",
      "cStandard": "c11",
      "intelliSenseMode": "linux-gcc-x64"
    }
  ],
  "version": 4
}
```
