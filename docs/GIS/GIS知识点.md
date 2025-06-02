**GIS地理信息系统**可以理解为基于地图来做管理和分析的软件系统，GIS的地图数据是带有位置、坐标等信息的数据库。
GIS技术分两层，一是后台服务（例如Geoserver、arcgis server），提供地图数据访问服务，支持不同组织提供的多种数据规范包括WMS、WMTS、WCS、TMS等。二是渲染服务，即将后台数据进行可视化。
![](assets/gis_arch_layer.png)

**GIS数据类型**包括图片、矢量和栅格数据，其中：

- 矢量数据是由点、线、多边形（区域）组成，用空间坐标x，y表示地理实体的位置和形状的数据，例如矢量点表示经纬度，河流、道路、管线显示为矢量线，多边形则表示区域边界，如建筑占地面积；
    
- [栅格网格格式](https://www.zhihu.com/search?q=%E6%A0%85%E6%A0%BC%E7%BD%91%E6%A0%BC%E6%A0%BC%E5%BC%8F&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)是卫星数据和其他遥感数据的数据模型，栅格数据由像素（也称为网格单元）来表示连续的空间实体，例如海拔表面、温度变化、铅污染等。栅格中的每个像素都有自己的值或类别。

**3D引擎**是一套帮助开发者去构建和呈现3D图形和场景的工具。3D引擎通常包括一个图形渲染器，用于创建逼真的3D图像，以及一个物理引擎，用于处理物理交互和碰撞检测。它们还可以提供脚本语言和场景编辑器，用于导入和管理游戏资源并且创建和编辑场景、对象、动画和特效等。3D引擎作为一种底层工具支持着高层的图形软件的开发，可以将其理解为对一些图形通用算法、底层工具和3D API的封装、利用它可以让用户专注于游戏逻辑的实现。
![[assets/Pasted image 20250602094934.png]]早期的工业可视化软件基本都使用OpenGL自己开发，OpenGL和DirectX是图形API（应用程序接口），它与GPU来对接，是通往CPU和GPU的桥梁； 后来出现的开源显示引擎，常用的比如Osg，Ogre，VTK等，底层也是调用OpenGL； **老牌图形厂家**一般使用Ogre、Osg、OsgEarth、VTK、Unigine等图形引擎，架构相对较老，只支持C/S应用，大部分此类公司还会再开辟一条B/S引擎线。

- OGRE多用于游戏开发、**OSG**多用于仿真开发，在GIS领域应用较多，但场景细节相较[游戏引擎](https://www.zhihu.com/search?q=%E6%B8%B8%E6%88%8F%E5%BC%95%E6%93%8E&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)渲染效果较差；
    
- **OSGEarth**是在OSG的基础上封装的三维GIS引擎，能够加载常见的GIS数据以及OGC服务，OSGEarth普及程度非常高，国内也有很多公司基于OSGEarth，推出所谓的自研引擎，例如：[恒歌科技](https://www.zhihu.com/search?q=%E6%81%92%E6%AD%8C%E7%A7%91%E6%8A%80&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)-FreeXGIS Desktop 战场态势仿真系统。
    

**游戏和仿真跨界的厂家**一般使用UE4、Unity等游戏引擎，如今的游戏引擎已经发展为一套由多个子系统共同构成的复杂系统，从建模、动画到光影、粒子特效，从物理系统、碰撞检测到文件管理、网络特性，还有专业的编辑工具和插件，几乎涵盖了游戏开发过程中的所有重要环节。

- **UE4**是3A游戏首选，侧重于PC端，擅长小场景的细节效果展示，引擎大部分业务层代码开源，支持蓝图、C++，学习成本较高。代表作有腾讯的“和平精英”，UE4目前可通过Cesium for Unreal、SupeMap Scense SDKs 组件，实现了游戏引擎和GIS引擎的跨界融合；
    
- **Unity**侧重轻量级的开发，偏向于移动端，Unity支持C#，学习成本更低，但其引擎源码不公开，启动需要联网。代表作有“王者荣耀”、“纪念碑谷”、“原神”，Unity也可通过插件的形式实现与GIS的融合。
    
- 为了提高GIS数据的真实还原度，目前GIS与游戏引擎的结合也是一大技术融合趋势。三维GIS通过融合游戏引擎，实现实时加载真实[地理坐标系](https://www.zhihu.com/search?q=%E5%9C%B0%E7%90%86%E5%9D%90%E6%A0%87%E7%B3%BB&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)下的地形、影像、倾斜摄影模型、激光点云、手工建模数据、BIM模型等多源异构的[地理空间数据](https://www.zhihu.com/search?q=%E5%9C%B0%E7%90%86%E7%A9%BA%E9%97%B4%E6%95%B0%E6%8D%AE&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)，打通三维GIS与游戏引擎的跨界融合，将具有真实地理坐标的室外地理环境、室内BIM模型、实时的IoT（物联网）数据等融合到游戏引擎，构建一个室内/室外一体化、宏观/微观一体化、空天/地表/地下一体化的.
- **B端图形厂家**一般使用Cesium.js，Three.js，这也是一些老牌图形厂家支持B/S技术的引擎选择，GIS的开发和应用未来多倾向于WebGIS。

- **WebGIS**是Web技术应用于GIS开发的产物，GIS通过Web功能得以扩展，既具有空间数据的检索、查询、编辑、分析、输出等传统GIS功能，同时能实现数据的协作和共享。
    
- Web前端可视化技术（当下WebGL、未来WebGPU）与GIS技术深度融合，涌现出一批优秀的开源框架：a. 处理二维GIS的**openlayers、leaflet**；b. 处理二三维一体化的**[cesium](https://www.zhihu.com/search?q=cesium&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)****、MapBox**；常见的的WebGIS应用场景包括：a. 政务Charts可视化图表；b. LBS Location Based Service地图[开放平台](https://www.zhihu.com/search?q=%E5%BC%80%E6%94%BE%E5%B9%B3%E5%8F%B0&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)（高德、谷歌、百度、[天地图](https://www.zhihu.com/search?q=%E5%A4%A9%E5%9C%B0%E5%9B%BE&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)）；c. 商业API（[中地数码](https://www.zhihu.com/search?q=%E4%B8%AD%E5%9C%B0%E6%95%B0%E7%A0%81&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra=%7B%22sourceType%22%3A%22answer%22%2C%22sourceId%22%3A3424505738%7D)的MapGIS Client for JS、超图的IClient、ESRI）。

DEM（Digital Elevation Model，数字高程模型）是一个广义的术语，表示地球表面高度信息的数字模型，它通过网格形式存储地形的高程数据，可以包括 DSM 或 DTM 的内容。因此，DEM 可以理解为一个总括性的名称，用来描述任何关于地表高度的数字模型。
DSM（Digital Surface Model，数字表面模型）是一种更为具体的高程模型，表示的是包括地表所有物体的高度。这意味着它不仅考虑裸露地面的高度，还包括地表上覆盖的物体，如建筑物、树木、植被等。
DTM（Digital Terrain Model，数字地形模型）是另一种具体的高程模型，专注于表示裸露的地形高程，去除了地表上的所有物体（如树木、建筑物）。它只反映地球表面的真实地形起伏，因此它更加准确地描绘了地面本身的形态。
DOM（Digital Orthophoto Map，数字正射影像图）是指经过几何校正处理的航空影像或卫星影像。这种影像去除了由于地形起伏、传感器倾斜和透视造成的几何畸变，使得每个像素都与地面的实际位置精确对应，类似地图上的投影。因此，DOM 可以用作精确的测绘基础，并与其他地理信息系统（GIS）数据进行配合使用。
TDOM（True Digital Orthophoto Map，真彩色数字正射影像图）是指以自然颜色为基础的数字正射影像图。它是一种经过几何校正的影像数据，其中影像的色彩真实反映了地表的自然颜色，没有经过人为色彩调整或增强。TDOM 与普通的数字正射影像（DOM）类似，但强调了其真实的色彩还原，主要用于需要真实色彩表现的应用场景。
是将DOM纠正为垂直视角的影像产品，对各种地物、地形、植被等的倾斜投影(地物隐蔽部分）采用相邻像片修正，从而形成地物没有投影差、建筑物间无遮挡的正射影像图。
https://www.cnblogs.com/gooutlook/p/17807986.html
DLG（Digital Line Graph，数字线划图）是一种以数字形式存储地理信息的线条图，表示地理要素的几何形状和空间分布。DLG 主要包含地形和地理要素的线条数据，如河流、道路、行政边界、等高线等。
**倾斜摄影**（Oblique Photography）是一种摄影测量技术，突破了传统正射影像只有垂直角度的局限，通过无人机搭载多台传感器，同时从一个垂直、四个倾斜等五个不同的角度采集影像，能够实现大规模区域的快速三维重建，并以真实影像作为模型贴图，是对真实世界进行快速三维重建的有效方式。
倾斜摄影加工流程，需要的设备和工作包括：
• 航空载具：目前实际采集以无人机为主，可以是旋翼机或者复合翼；大疆系列无人机应用很多；
• 影像采集设备：多目倾斜摄影相机，常见的如5镜头相机；选择合适的拍摄软件如Altizure等；
• 影像采集：包括航线规划、飞线采集，以及相关的安全飞行保障；目前国家对无人机的使用是有相应法规管控的，不能随意飞行；
• 采集数据处理：航拍采集的影像，通过专用的处理软件，经过点云生成、tin网、构建白模、构建三维模型等步骤，生成最终的倾斜摄影模型；
• 较主流的软件包括了Smart3d、PIX4D MAPPER、PHOTOSCAN、Photomesh、街景工厂等；
• 目前主流的倾斜摄影格式是OSGB；根据密集点云逐级抽稀后构建的tin模型，自动创建LOD，实现不同层级之间的平滑过度；

![[assets/Pasted image 20250602095110.png]]

DEM有三种主要的表示模型：规则格网模型、等高线模型和不规则三角网。

栅格形式（GRID DEM）：最常见的形式，地表被划分成规则的网格单元，每个栅格单元包含一个高程值，通常以数字形式表示。栅格DEM适用于许多GIS软件，如ArcGIS和QGIS，以及用于地形分析、浸水模拟等应用。

TIN形式（Triangulated Irregular Network）：TIN DEM 使用不规则的三角形来表示地表，每个三角形由三个地点（点或节点）定义，包括高程值。TIN DEM 适用于描述不规则地形，因为它可以更精确地捕捉地表的曲线和斜坡。

点云形式（Point Cloud）：点云DEM是一组地理坐标点，每个点具有高程值。通常采用LAS（镭射扫描标准）文件格式来存储，用于激光雷达和三维扫描仪数据。点云DEM适用于高精度地形建模和3D地形分析。

矢量形式（Vector DEM）：矢量DEM使用矢量线段、多边形和多点数据来表示地表。这些数据通常用于地理信息系统（GIS）中，可以表示高程等值线、等高线和地形特征。

标量场形式（Scalar Field）：标量场DEM将高程信息表示为一个连续的标量场，其中每个点都具有高程值。通过数学方程式来描述地表，适用于地形建模和分析。

三维模型形式（3D Model DEM）：三维模型DEM使用三维模型文件格式（如COLLADA、OBJ等）来表示地表。这种形式通常用于三维建筑和城市模型，包括建筑物和地形。

  

数据格式：

.ddf USGS DEM

.dem Vista Pro Binary DEM

.dem USGS DEM

.hgt SRTM（航天飞机雷达地形测绘使命）

.tif GeoTIFF

.dem Vista Pro Binary DEM

  

1. USGS DEM：由美国地质调查局开发的一种早期标准格式，每个单元格代表一个固定面积内的平均海拔高度，存储为ASCII文本或 binary 格式。
    
2. ESRI GRID：作为ArcGIS平台支持的标准格式之一，GRID格式能有效储存DEM的数据结构与属性信息，包括像元大小、坐标系统以及镶嵌规则等详细参数。
    
3. DTED (Digital Terrain Elevation Data): 是军用领域广泛应用的一类全球统一规格的DEM格式，包含DTED Level 0至Level 2三种精度等级，分别对应不同的分辨率要求。
    
4. GeoTIFF: 这种基于 TIFF 图像格式扩展而来的 GIS 数据交换方式可以嵌入地理位置参考和其他元数据，适用于各种类型的遥感影像，当然也包含了用于表达DEM的空间向量信息。
    
5. LiDAR LAS/LAZ Format：针对激光雷达(LiDAR)采集得到的密集型 elevation 点云数据设计的专用格式，不仅记录了每一个测定点的位置与强度信息，还可承载颜色、分类等多种附加属性。
    

  

TIFF 与 GEO TIFF

https://www.cnblogs.com/arxive/p/6746570.html

文件格式：http://www.bimant.com/docs/3dformat/GeoTIFF/

https://blog.geohey.com/geotiff-shu-ju-ge-shi-tan-suo/

https://gisgeography.com/gis-formats/

  

  

Esri Grid

https://desktop.arcgis.com/zh-cn/arcmap/latest/manage-data/raster-and-images/esri-grid-format.htm

![[assets/Pasted image 20250602095141.png]]

https://zhuanlan.zhihu.com/p/695271819

  

**矢量切片**

[矢量切片规范](https://github.com/mapbox/vector-tile-spec)

[awesome-vector-tiles 整理搜集矢量切片相关的库](https://github.com/mapbox/awesome-vector-tiles)

  

矢量切片的常见格式：

Mapbox Vector Tiles (MVT)：Mapbox定义的格式，基于二进制的Protobuf编码，.pbf 结尾。

GeoJSON：基于GeoJSON格式，数据以JSON格式传输。

TopoJSON：GeoJSON的变体，通过消除冗余节点并共享边界来减少文件大小，适合描述复杂几何结构。

  

  

  

**抽稀和插值**