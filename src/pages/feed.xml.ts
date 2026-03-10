import rss from "@astrojs/rss";
import { getCollection } from "astro:content";
import sanitizeHtml from "sanitize-html";
import MarkdownIt from "markdown-it";
const parser = new MarkdownIt();

export async function GET(context: { site: string | URL }) {
  const blogEntries = await getCollection("posts");

  blogEntries.sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());

  return rss({
    title: "Ben C's Blog",
    description: "Talking about web development, NixOS, Linux customization, and more",
    site: context.site,
    items: blogEntries.map((post) => ({
      title: post.data.title,
      pubDate: post.data.date,
      description: post.data.summary,
      link: `/blog/posts/${post.id}`,
      content: sanitizeHtml(parser.render(post.body), {
        allowedTags: sanitizeHtml.defaults.allowedTags.concat(["img"])
      })
    })),
    customData: `<language>en-us</language>`
  });
}
