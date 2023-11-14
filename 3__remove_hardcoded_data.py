#!/usr/bin/env python3
# coding: utf-8

from bs4 import BeautifulSoup
from pathlib import Path
import re

def load_page(page_path):
    with open(page_path, "r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "html.parser")
    return soup

# 1. Remove all script tags but keep their src
def get_script_links(soup):
    script_links = []
    for script in soup.findAll("script"):
        if script.has_attr("src"):
            script_links.append(script.attrs["src"])
            script.decompose()
    return script_links

# 2. Move quarto-html-after-body and any other scripts to files
#    so they're not loaded before htmlwidgets etc. are loaded
def get_body_scripts(soup, page_name):
    body_scripts = []
    for i, script in enumerate(soup.html.body.findAll("script")):
        # don't copy the data scripts here
        if not script.has_attr("data-for"):
            if script.has_attr("id"):
                out_file = f"./{page_name}_files/libs/{script.attrs['id']}.js"
            else:
                out_file = f"./{page_name}_files/libs/body_script_{i}.js"
            with open(out_file, "w", encoding= "utf-8") as f:
                f.write(script.get_text())             
            body_scripts.append(out_file)
            script.decompose()
    return body_scripts

# 3. Remove the hardcoded json data and write to file
def remove_json_data(json_tag, page_name):
    Path(f"./{page_name}_files/data/").mkdir(exist_ok=True)
    el_id = json_tag.attrs['data-for']
    with open(f"./{page_name}_files/data/{el_id}.json", "w", encoding="utf-8") as f:
        f.write(json_tag.get_text()) 
    json_tag.string.replace_with("")
    return el_id

# 4. Create the javascript to load the data and scripts
def create_load_data_js(soup, page_name):
  script_links = get_script_links(soup)
  body_scripts = get_body_scripts(soup, page_name)
  json_tags = [script for script in soup.findAll("script") if script.has_attr("data-for")]
  el_ids = [remove_json_data(json_tag, page_name) for json_tag in json_tags]   

  load_function = """
    const loadScript = (file_url, async = true, type = "text/javascript", appendToHead = true) => {
        return new Promise((resolve, reject) => {
            try {
                const scriptEle = document.createElement("script");
                scriptEle.type = type;
                scriptEle.async = async;
                scriptEle.src = file_url;
                scriptEle.addEventListener("load", (ev) => {
                    resolve({ status: true });
                });
                scriptEle.addEventListener("error", (ev) => {
                    reject({
                        status: false,
                        message: `Failed to load the script ${file_url}`
                    });
                });
                appendToHead ? document.head.appendChild(scriptEle) : document.body.appendChild(scriptEle);
            } catch (error) {
                reject(error);
            }
        });
    };
  """

  load_data_first_element = f"""
  fetch("./{page_name}_files/data/{el_ids[0]}.json")
    .then((response) => response.json())
    .then(
      (json) =>
        (document.querySelectorAll('[data-for="{el_ids[0]}"]')[0].innerHTML =
          JSON.stringify(json).replaceAll("/", "/"))
    )
  """

  load_data_all_elements = [f"""
      .then(() => fetch("./{page_name}_files/data/{el_id}.json"))
      .then((response) => response.json())
      .then(
        (json) =>
          (document.querySelectorAll('[data-for="{el_id}"]')[0].innerHTML =
            JSON.stringify(json).replaceAll("/", "/"))
      )
    """ for el_id in el_ids]

  if(len(el_ids) > 1):
    load_data_all_elements.pop(0)
    load_data_next_elements = "".join(load_data_all_elements)
  else:
    load_data_next_elements = ""

  then_load_scripts = "\n".join([f'.then(() => loadScript("{script}"))' for script in script_links])
  then_body_scripts = "\n".join([f'.then(() => loadScript("{script}"))' for script in body_scripts])
  then_render_mermaid = ".then(() => window.mermaid.init())" # mermaid charts will not render otherwise
  then_render_html = ".then(() => window.HTMLWidgets.staticRender());"

  script_content = f"""
  {load_function}
  {load_data_first_element}
  {load_data_next_elements}
  {then_load_scripts}
  {then_body_scripts}
  {then_render_mermaid}
  {then_render_html}
  """
  return script_content

def insert_main_js_script(soup, page_name):
    load_data_js = create_load_data_js(soup, page_name)
    s = soup.new_tag("script")
    s.string = load_data_js 
    soup.html.head.append(s)   

def save_new_html(soup, page_name):
    outfile = f"{page_name}_min.html"
    with open(outfile, "w", encoding='utf-8') as file:
        file.write(str(soup))
    print(f"File created: {outfile}")

def create_page_min(page_path):
    soup = load_page(page_path)
    page_name = re.sub("\\.html$", "", page_path.name)
    print(f"Converting {page_path}")
    insert_main_js_script(soup, page_name)
    save_new_html(soup, page_name)

def make_all_html_min(files_to_exclude = ["example_file_to_exclude.html"]):
    # .endswith("min") is quick and dirty shortcut to not apply this script to files it creates
    files_to_make_min = [f for f in Path("./").glob("*.html") if not f.name.endswith("min.html")]
    files_to_make_min = list(set(files_to_make_min) - set([Path(f) for f in files_to_exclude]))

    print("This script will create a minimal version of the following files:""")
    for file in files_to_make_min:
        print(f"    -    {file.name}")
    input("To continue press any key or to cancel press Ctrl+C")
        
    for page_path in files_to_make_min:
        create_page_min(page_path)

make_all_html_min()

