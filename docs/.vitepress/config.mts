import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "左丘的博客",
  description: "All good things must come to an end.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: '首页', link: '/' },
      {
        text: '大数据',
        items: [
          { text: 'flink', link: '/bigdata/flink.md' },
          { text: 'flink部署', link: '/bigdata/flink-deploy.md' },
        ]
      },
      {
        text: '操作系统',
        items: [
          { text: '概述', link: '/cs/system/index.md' },
        ]
      }
    ],

    sidebar: [
      {
        text: 'Examples',
        items: [
          { text: 'Markdown Examples', link: '/markdown-examples' },
          { text: 'flink', link: '/flink' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/vuejs/vitepress' }
    ]
  }
})
