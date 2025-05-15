### Java环境配置

依赖扩展：
Code Runner
Extension Pack for Java
Hex Editor
Springboot

终端乱码，搜索下面配置修改，`Command Prompt`名字不要修改，有些配置会根据这个命令调用。
```json
"terminal.integrated.profiles.windows": {
	"Command Prompt": {
		"path": "C:\\Windows\\System32\\cmd.exe",
		"args": ["-NoExit", "/K", "chcp 65001"]
	},
	"PowerShell": {
		"source": "PowerShell",
		"args": ["-NoExit", "/C", "chcp 65001"]
	},
	"Git Bash": {
		"source": "Git Bash"
	}
},
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

