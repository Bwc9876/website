#import "@preview/basic-resume:0.2.9": *

#let name = "Benjamin Crocker"
#let location = "West Chester, PA"
#let email = "bc1016579@wcupa.edu"
#let github = "github.com/Bwc9876"
#let linkedin = "linkedin.com/in/bwc9876"
#let personal-site = "bwc9876.dev"

#set document(
  title: "Benjamin Crocker Resume",
)

#show: resume.with(
  author: name,
  location: location,
  email: email,
  //github: github,
  //linkedin: linkedin,
  personal-site: personal-site,
  accent-color: "#26428b",
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: left,
  personal-info-position: left,
)

/*
 * Lines that start with == are formatted into section headings
 * You can use the specific formatting functions if needed
 * The following formatting functions are listed below
 * #edu(dates: "", degree: "", gpa: "", institution: "", location: "", consistent: false)
 * #work(company: "", dates: "", location: "", title: "")
 * #project(dates: "", name: "", role: "", url: "")
 * certificates(name: "", issuer: "", url: "", date: "")
 * #extracurriculars(activity: "", dates: "")
 * There are also the following generic functions that don't apply any formatting
 * #generic-two-by-two(top-left: "", top-right: "", bottom-left: "", bottom-right: "")
 * #generic-one-by-two(left: "", right: "")
 */
== Education

#edu(
  institution: "West Chester University",
  location: "West Chester, PA",
  dates: dates-helper(
    start-date: "Aug. 2023",
    end-date: "May 2027 (Projected)",
  ),
  degree: "Bachelor of Computer Science, Minor in Professional and Technical Writing",
  consistent: true,
)
- Dean's List Fall 2023
- President of Computer Science Club
- Treasurer of: Competitive Programming Club, Cybersecurity Club, AI & Machine Learning Club

#edu(
  institution: "Berks Career and Technology Center",
  location: "Leesport, PA",
  dates: dates-helper(start-date: "Aug. 2020", end-date: "May 2023"),
  degree: "Information Technology Programming",
  consistent: true,
)
- Part-time student working on software development in VB.NET Winforms and learning various aspects of the Software Development Life Cycle (SDLC)

== Work Experience

#work(
  title: "Help Desk Consultant",
  location: "West Chester, PA",
  company: "West Chester University",
  dates: dates-helper(start-date: "Jan. 2024", end-date: "Present"),
)
- Supported users with various on-campus systems, including the RamPortal SIS
- Tested and found security issues on university endpoints and systems

#work(
  title: "Information Technology Intern",
  location: "Limerick, PA",
  company: "The Victory Bank",
  dates: dates-helper(start-date: "May 2023", end-date: "Aug. 2023"),
)
- Troubleshooted and provided support for endpoint devices, performed device imaging and configuration
- Supported VDI environments and maintenance of an ActiveDirectory domain

== Projects

#project(
  name: "West Chester University ASL Interface",
  // Role is optional
  role: "Contributor",
  // Dates is optional
  dates: dates-helper(start-date: "Feb. 2025", end-date: "Present"),
  url: "github.com/amiruzzaman/ASL_research",
)
- Web interface for translating ASL to English and vice-versa
- Frontend built in AstroJS with Tailwind and daisyUI
- Live rendering of ASL animations (landmark data rendered to a Canvas to look like a person signing ASL) via JavaScript
- Connects to backend running a Flask web server to handle computationally complex tasks

#project(
  name: "West Chester Programming Competition",
  // Role is optional
  role: "Author",
  // Dates is optional
  dates: dates-helper(start-date: "May 2024", end-date: "Present"),
  // URL is also optional
  url: "bwc9876.dev/projects/wcpc",
)
- Web interface for holding and participating in the West Chester Programming Competition
- Built with a Rust backend and SQLite Database (can be switched)
- Uses AstroJS to build most of the frontend with Tailwind. Pages are server-side rendered (SSR) with Tera
- Supports SSO login with user's WCU account and OAuth account linking for easier sign-in later
- Users can submit code that is run in a sand-boxed "jail". Code output is tested against expected output for scoring
- Live leaderboard for tracking competitions, ability for competitors to export their code as a Git repository

#project(
  name: "Outer Wilds Mod Manager",
  // Role is optional
  role: "Author",
  // Dates is optional
  dates: dates-helper(start-date: "Dec. 2022", end-date: "Present"),
  // URL is also optional
  url: "outerwildsmods.com/mod-manager",
)
- Built and maintained free desktop application for downloading and managing mods for the game Outer Wilds
- Built in Tauri with Rust for application logic and a web UI frontend built in React with MUI
- Distributed on various platforms including Windows, MacOS, Linux, Steam Deck

== Certificates

#certificates(
  name: "PA State Skills Certification - Computer Technology / Systems",
  issuer: "NOCTI",
  date: "May 2023",
)

#certificates(
  name: "OSHA 10 Hour General Industry Safety and Health",
  issuer: "OSHA",
  date: "Mar. 2023",
)

== Skills
- *Programming Languages*: Rust, JavaScript, TypeScript, Python, C\#, SQL, Visual Basic .NET
- *Technologies*: Git VCS, React, AstroJS, Tailwind, CSS, SASS, Bootstrap, MUI, Tauri, SAML, OAuth, LDAP, ActiveDirectory, GitHub Actions, Nix

