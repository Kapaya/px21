---
title: "Towards End-user Web Scraping For Customization"
author: "Kapaya Katongo, [Geoffrey Litt](https://www.geoffreylitt.com/) and [Daniel Jackson](http://people.csail.mit.edu/dnj/)"
bibliography: references.bib
link-citations: true
csl: templates/acm.csl
reference-section-title: References
figPrefix:
  - "Figure"
  - "Figures"
secPrefix:
	- "Section"
	- "Sections"
abstract: |
 Websites are malleable: users can install browser extensions and run arbitrary Javascript in the developer console to change them. However, this malleability is only accessible to programmers with knowledge of HTML, CSS, Javascript and the DOM. To broaden access to customization, our prior work developed an approach that empowers end-users to customize websites without traditional programming via a browser extension called Wildcard.

 Wildcard’s customizations are powered by web scraping adapters which are currently written in Javascript by programmers. This means that end-users can only customize a website if a programmer has written an adapter for it. Furthermore, end-users do not have the ability to extend adapters in order to perform new customizations or repair adapters to fix broken customizations.

 In this paper, we present our progress towards end-user web scraping for customization which empowers end-users to create, extend and repair adapters by demonstration. We describe three design principles that guided our system's development and are applicable to other end-user web scraping and customization systems: (a) users should be able to scrape data and use it in a unified environment, (b) users should be able to extend and repair the programs that scrape data via demonstration and (c) users should receive live feedback during their demonstrations.
 
 We have succesfully used our system to create, extend and repair adapters by demonstration on a variety of websites and provide example usage scenarios that showcase each of our design principles.
---

# Introduction {#sec:introduction}

Many websites on the internet do not meet the exact needs of all of their users. End-user web customization systems like Chickenfoot [@bolin2005], Thresher [@hogue2005], Sifter [@huynh2006] and Vegemite [lin2009] help users tweak and adapt websites to fit their unique requirements, ranging from reorganizing or annotating content on the website to automating common tasks. In our prior work, we presented Wildcard [@litt2020a], a customization system which enables end-users to customize websites through direct manipulation. It does this by augmenting websites with a table view that shows their underlying structured data. The table is bidirectionally synchronized with the original website, so end-users can easily customize the website by interacting with the table, including sorting and filtering data, adding annotations, and running computations in a spreadsheet formula language.

Wildcard has a key limitation. In order to enable end-users to customize a website, a Javascript programmer first needs to code an adapter that specifies how to scrape the website content and set up a bidirectional synchronization with Wildcard's table view. Take Alice, an end-user that uses Wildcard to customize her experience on Google Scholar. Wildcard's sorting customization gives her the power to sort publications by title which the website does not natively allow. She thinks this will be useful on Weather.com to sort the ten day forecast by the weather descriptions so that she can quickly find all the sunny days. Unfortunately, a programmer has not coded an adapter for Weather.com so Alice is unable to customize it. Additionally, if the adapter for timeanddate.com, which she uses to sort the list of holidays in a year, does not scrape all the data she wats, or the adapter for Google Scholar stops functioning when the website changes, Alice has no recourse to extend or repair them on her own.

In this paper, we describe an addition to Wildcard: a system that enables end-users to create, extend and repair website adapters by demonstration within the browser. Using this scraping system, an end-user can perform end-to-end web customizations using Wildcard on arbitrary websites, without ever needing to code an adapter. Through a series of examples, we show that end-users can utilize our system to successfully create Wildcard adapters on a variety of websites via demonstration ([@sec:demos]). We also describe key aspects of our system and how web scraping for customization reveals a constraint that simplifies the *wrapper induction* [@kushmerick2000] task used to generalize user demonstrations ([@sec:implementation]).

Our key contribution is a set of three design principles that guided the design of our system, which also offer insights that might be applied to other end-user web scraping and customization tools ([@sec:design-principles]):

- **Unified Environment**: Users should be able to scrape data and interact with the scraped data in a single environment. This minimizes the barrier to fluidly switching back and forth between the two tasks, rather than treating them as entirely independent tasks.
- **Editing By Demonstration**: Users should be able to not only create programs for scraping data by demonstration, but also extend and repair the programs by demonstration. This enables users to build on other user's work, and is especially important in the context of web scraping since programs that scrape data sometimes break as the underlying website changes.
- **Live Programming**: Users should receive live feedback as they perform demonstrations. The system should indicate how it is generalizing from the user's example and what the resulting data will look like, so that the user can adjust their demonstrations on the fly and quickly arrive at the desired result.

Finally, we share our broader vision for web scraping for customization, and some opportunities for future work, including a proposal for how Wildcard’s spreadsheet-like formula language might augment demonstrations to provide end-users with more expressiveness in the web scraping process ([@sec:conclusion]).

# Motivating Examples {#sec:demos}

In this section, we show how end-users can create, extend and repair adapters for Wildcard via demonstration.

## Creating An Adapter

Alice, our end-user from [@sec:introduction], has heard that Wildcard now provides a way for none-programmers to create, extend and repair website adapters needed to enable customizations. This will allow her to customize her experience on Weather.com by sorting the ten-day forecast based on the description of the weather on each day, allowing her to easily view all the sunny days. She starts the adapter creation process by clicking a context menu item within the Weather.com page, and hovers over a data value she might like to scrape.

<video controls="controls" muted="muted" src="media/2.1.1.mp4" muted playsinline controls class>
</video>

The system provides live feedback as Alice hovers:

- The selected row of data is annotated in the page with a border, to indicate that she will be demonstrating values from within that row.
- The selected column of data is highlighted in the page with a green background, to show how the system has generalized her demonstration across all the rows in the data.
- A table view appears at the bottom of the screen, and displays how the values will appear in the data table.

Alice tries hovering over several other elements in the page, taking advantage of the **live programming** environment to decide what data would be useful. After considering several options, she decides to save the date field in the first column of the table, and commits the action by clicking.

<video controls="controls" muted="muted" src="media/2.1.2.mp4" muted playsinline controls class>
</video>

Next, she performs a similar process to fill the next column with the weather descriptions. After filling both columns, she also tries hovering over previously scraped data, and the toolbar at the top of the page indicates which column corresponds to the previously scraped data. Finally, she ends the adapter creation process and is able to immediately sort the forecast by the weather description column because Wildcard provides a **unified environment** for scraping and customizing:

<video controls="controls" muted="muted" src="media/2.1.3.mp4" muted playsinline controls class>
</video>

## Extending An Adapter

Alice recalls that she also uses Wildcard to customize timeanddate.com. In addition to sorting the list of holidays in a year by the day of the week, she also wants to sort them by the type of holiday. This would let her view the all federal holidays together for example. Previously, she would have needed to find a programmer to help her edit the adapter code. Using our system, Alice can extend the adapter herself.

Once on timeanddate.com, she clicks the "Edit Scraper" button on top of Wildcard's table to initiate the adapter editing process. As she hovers over the currently scraped values, the columns they belong to are highlighted. Finally, she clicks on “Federal Holiday” to add the new column of data and saves the changes. Alice then proceeds to sort the list by the type of holiday without the intervention of a programmer, a task made possible because of **editing by demonstration**.

<video controls="controls" muted="muted" src="media/2.3.2.mp4" muted playsinline controls class>
</video>

## Repairing An Adapter

Having procrastinated enough, Alice returns to Google Scholar to look up references for her thesis project. Unfortunately, the customization she had applied to sort publications by their title (which is not natively supported by Google Scholar) is no longer working. In fact, the column in the Wildcard table that contained all the publication titles is empty. Unbeknownst to her, the website's internals had changed as a result of a update.

To fix this, Alice initiates the editing process, and initially hovers over the desired value to demonstrate the column she wants to scrape. However, she notices that the values would be populated into column D; instead, she wants the values to be inserted into column A where they previously appeared. Alice clicks on the symbol for column A to indicate that he wants to scrape the values into that column. She then proceeds to re-apply her customization to the website by sorting the publications by their title without the intervention of a programmer, another task made possible because of **editing by demonstration**.

<video controls="controls" muted="muted" src="media/2.4.2.mp4" muted playsinline controls class>
</video>

# System Implementation {#sec:implementation}

We implemented our end-user web scraping system as an addition to the Wildcard browser extension. We start by describing our implementations of row and column generalization, live programming and editing by demonstration and end by discussing some of the current limitations of our system.

## Generalization Algorithms

In order to generate reusable scrapers from user demonstrations, our system solves the *wrapper induction* [@kushmerick2000] task: generalizing from a small set of user-provided examples to a scraping specification that will work on other parts of the website, and on future versions of the website.

We take an approach similar to that used in other tools like Vegemite [@lin2009] and Sifter [@huynh2006]:

- We generate a single *row selector* for the website: a CSS selector that returns a set of DOM elements corresponding to individual rows of the table.
- For each column in the table, we generate a *column selector*, a CSS selector that returns the element containing the column value within that row.

One important difference is that our algorithm only accepts row elements that have direct siblings with a similar structure. We refer to this as the *row-sibling* constraint. Later in this section, we describe how the constraint provides a useful simplification of the wrapper induction task and discuss the resulting limitations this puts on our system in a section that follows.

When a user first demonstrates a column value, the generalization algorithm is responsible for turning the demonstration into a row selector that will correctly identify all the row elements in the website and a column selector that will correctly identify the element that contains the column value within a row element. During subsequent demonstrations, the generalization algorithm uses the generated row selector to find the row element that contains the column value and generates a column selector which identifies the corresponding column element.

At a high level, the generalization algorithm’s challenge is to traverse far enough up in the DOM tree from the demonstrated element to find the element which corresponds to the row. We solve this using a heuristic; the basic intuition is to find a large set of elements with similar parallel structure. Consider the following sample HTML layout, which displays a truncated table of superheroes, with each row containing some nested structure:

```html
<body>
    <h1> Team Iron Man </h1>
    <div class=’container’>
        <div class='avenger'>
            <div class='names'>
                <span class='super_hero_name'> Iron Man </span>
                <span class='real_name'> Tony Stark </span>
            </div>
           <span class=’gender’> Male </span>
        </div>
        <div class='avenger'>
            <div class='names'>
                <span class='super_hero_name'>  Black Widow </span>
                <span class='real_name'> Natalia Romanoff </span>
            </div>
            <span class=’gender’> Female </span>
        </div>
        ...
    </div>
</body>
```

The user performs a demonstration by clicking on the SPAN element containing “Tony Stark”. Our algorithm traverses upwards from the demonstrated element, considering each successive parent element as a potential candidate for the row element. For each parent element $n$, the process is as follows:

1. compute a selector $s$ that when executed on $n$ only returns the demonstrated element
2. for each sibling $m$ of $n$, execute $s$ on $m$ and record whether the selector returned an element. Intuitively, if the selector returns an element, this suggests that the sibling $m$ has some parallel structure to $n$
3. compute $n_{siblings}$, the number of sibling elements of $n$ for which $s$ returned an element

Notice how the row-sibling constraint simplifies the problem: row candidates without siblings that return an element after $s$ is executed on them have $n_{siblings}$ = 0, thus disqualifying them. Furthermore, a candidate element $n$ is only accepted as the row element if the row selector associated with it only matches itself and elements that are its direct siblings.

From the parent of the initial SPAN element, the algorithm moves up the DOM tree until it reaches the BODY element. Then, it generates a selector for each $n$ and discards any $n$ with a selector that matches elements that are either not itself or a direct sibling. Finally, the algorithm picks an $n$ with the largest, positive $n_{siblings}$, preferring nodes lower in the tree as a tiebreaker. $s$ is used as the selector for the column.

In the above sample DOM, the first parent element is the DIV with class *names* when the user clicks on the SPAN element containing “Tony Stark”. This DIV has a sibling SPAN element, but the sibling doesn’t return an element when *.super_hero*, the selector that identifies the initial SPAN in the DIV, is executed on it. As a result, it has $n_{siblings}$ = 0. At the level above that, we consider the DIV with class *avenger*, which has at least one sibling that returns an element when the selector *.super_hero* is executed on it. Finally, the level above that once again has no siblings that return an element when the selector *.super_hero* is executed on them. Therefore, our algorithm returns the DIV element and outputs *.avenger* as the row selector and *.super_hero* as the column selector. These selectors are used to generate a DOM scraping adapter which returns the DOM elements corresponding to a superhero data row in the table.

## Live Programming

Live programming is implemented by continually running the generalization algorithm on the DOM element under the user’s cursor, reverting if the user hovers away and committing when the user clicks. The generated row and column selectors are used to highlight all the matching elements on the website and create an adapter. Highlighting all the matching column elements on the website provides visual feedback about the system’s generalization to the user. Creating an adapter enables the system to  populate the table view and set up the bidirectional synchronization. Because the table is populated and the bidirectional synchronization is set up, users can customize as they scrape.

## Editing By Demonstration

The implementation of the editing by demonstration feature is rather simple. Because users interact with the scraped data directly in the context of the website, it is easy to re-initiate the scraping system. Our system generates adapters with metadata that can be used to boot it up. The metadata simply consists of the row selector and the column selectors. Our generalization algorithm takes the provided row selector and uses it to generate new column selectors. We are keen to explore what other implementations of programming by demonstration this can be done for and what the implications and benefits would be.

## Limitations

The row-sibling constraint we mentioned earlier is important for the end goal of customization because row elements that are not direct siblings may not represent data on the website that should be related as part of the same table by customizations such as sorting and filtering. Take the following sample HTML layout showing two tables of superheros  (Team Iron Man and Team Captain America):

```html
<body>
  <h1> Team Iron Man </h1>
  <div class=’container’>
      <div class='avenger'>
          <span class='super_hero_name'> Iron Man </span>
      </div>
      <div class='avenger'>
          <span class='super_hero_name'>  Black Widow </span>
      </div>
      ...
  </div>
  <h1> Team Captain America </h1>
  <div>
      <div class='avenger'>
          <span class='super_hero_name'> Captain America </span>
      </div>
      <div class='avenger'>
          <span class='super_hero_name'>  Scarlet Witch </span>
      </div>
      ...
  </div>
</body>
```

Without the constraint that row elements have to be direct siblings, the row generalization algorithm could determine the row selector to be *.avenger* because it matches the most number of parallel structures (has the largest $n_{siblings}$). While this may be the correct result for the task of extraction, it is not for the task of customization. The selector matches all rows across the two tables so the sorting and filtering customizations could place rows in the incorrect table and thereby distort what the tables represent. Because of this, our system currently does not support generalizing over websites with such HTML layouts but we plan to explore the possibility of extracting multiple tables from a website and joining them.

Another HTML layout that our system cannot currently generalize over is one in which column elements are not contained within a row element that is a direct sibling of all the other row elements. Take the following sample HTML layout showing a table of superheros:

```html
<body>
  <h1 class='super_hero_name'> Iron Man </h1>
  <span class='real_name'> Real Name: Tony Stark </span>
  <h1 class='super_hero_name'> Captain America </h1>
  <span class='real_name'> Real Name: Steven Rogers </span>
  <h1 class='super_hero_name'> Black Widow </h1>
  <span class='real_name'> Real Name: Natalia Romanoff </span>
  ...
</body>
```

The HTML contains one table of data in which rows are made up of an H1 tag (super hero name) and a SPAN tag (real name). For the task of extraction, the DOM elements can be scraped using the shown classes to output a table in which the values of the H1 tags form the first column and the values of the SPAN tag form the second column. For the task of customization, our system would need to know what the row boundaries are in order for customizations such as sorting and filtering to not distort the representation of the website. This can be done in adapters written by a programmer by creating artificial row boundaries. In the above DOM structure, an artificial row boundary could be created by representing a row as an H1 tag and the SPAN tag that immediately follows it. These artificial rows would form a single unit which would not distort the website after a sorting or filtering customization. We plan to explore how artificial row boundaries can be created via demonstration in order to support such DOM structures which are not uncommon (HackerNews has this type of DOM structure).

# Design Principles {#sec:design-principles}

Below, we discuss the design principles underlying our work.

## Unified Environment

In the previous iteration of Wildcard, web scraping was an entirely separate activity from customization. Programmers that wrote scraping adapters would need to switch into an IDE to write code as part of customizing a new website, making it a much less unified environment. This type of divide between tasks appears in other tools and is undesirable to users. The creators of Wrex [@drosos2020], a programming-by-example system for data wrangling, reported that "although data scientists were aware of and appreciated the producitivy benefits of existing data wrangling tools, having to leave their native notebook environment to perform wrangling limited the usefulness of these tools." 

In the domain of web scraping, scraper creation is treated as a specialized step, distinct from other stages of work. The scraped data is exported to a database or a spreadsheet for further processing: if the user comes across an omission or a problem while working with the data, they need to switch environments to edit the scraping logic. The problem also emerges in web customization tools more similar to Wildcard, like Vegemite [@lin2009], which had separate steps for selecting and augmenting data. In a user study of Vegemite, participants reported that “it was confusing to use one technique to create the initial table, and another technique to add information to a new column.'"

In this work, we have combined scraping and customization into a unified activity within a single environment. The goal is to minimize the environment switch between *extracting* the data and *using* the data. A user might start out by scraping some data, and then switch to customizing the website using the results. Then, they might realize they need more data to perform their desired task, at which point they can easily augment the adapter by demonstrating new columns. All of these tasks take place right in the browser, where the user was initially already using the uncustomized website. Instead of bringing the data to another tool, we have brought a tool to the data.

Of course, there is value in specialized tools: Wildcard has nowhere near the full capabilities of spreadsheet software or databases. Nevertheless, we believe a unified environment for scraping and customization presents a significantly lower barrier to entry for customization.

## Editing By Demonstration

Many end-user web scraping and macro systems allow users to create programs by demonstration but do not offer a way to edit them by demonstration. In Rousillon [@chasins2018], a web scraping program created by demonstration can only be edited through a high-level, block-based programming language. In Vegemite [@lin2009], an automation program created through demonstration can only be edited by editing the text-based representation of the program.

In Wildcard, if a website’s adapter ceases to function because the website changes, the table may lose its data which means that an end-user’s customizations may also cease to function. Furthermore, end-users are powerless to extend the scraping adapter to add columns to the table in order to perform new customizations. This goes against MacLean et. al.'s vision of user-tailarable systems [@maclean1990] that give users "a feeling of ownership of the system, to feel in control of changing the system and to understand what can be changed." Providing an easy way for users to edit programs is therefore fundamental to fully democratizing web customization.

Editing by demonstration promises to make end-users first-class citizens in the customization ecosystem. Because users interact with the scraped data directly in the context of the website, it is easy to re-initiate the scraping system. The edit process simply boots up the scraping system using metadata stored with the scraping adapter to the state when the demonstration was completed. Users that have gone through the creation process will immediately realize what to do in order to extend or repair the adapter. Users that have not gone through the creation process might have a harder time but we provide visual clues (such as highlighting the row to perform demonstrations from with a green border) and live programming (immediately preview the results of demonstrations) that serve as guides.

Editing by demonstration in the web scraping domain is feasible because the programs that scrape column values are independent of each other: changing the program that scrapes values into column A has no effect on the program that scrapes values in column B. However, changing the program that retrieves rows would affect the programs that scrape values into columns because they are dependent on the values being available in a row. This is therefore not supported but is an acceptable limitation for us given our focus on extension and repair which only deal with programs that scrape column values.

This design principle is related to the idea of “in-place toolchains” [@zotero-60] being an integral part of end-user programming systems. The authors champion the practice of end-user programming systems allowing users to edit programs “using an interface and set of abstractions that is as close as possible to the ones they use for their regular daily work.”

## Live Programming

In some end-user web scraping systems like Rousillon [@chasins2018], users only get *full* feedback about the program’s execution (generalization and the scraped values) after providing all the demonstrations. This means they cannot adjust their demonstrations in response to the system’s feedback as they demonstrate.

Our end-user web scraping system employs live programming techniques to eliminate this edit-compile-debug cycle by running the generalization algorithm and generating an adapter after each user demonstration. As we show in [@sec:demos], when a user demonstrates a value of a column they wish to scrape, our system immediately shows how it has generalized the user’s demonstration across the other rows of the data by highlighting the all relevant values. It also populates the table with the scraped data based on the latest demonstration. The highlighting and table population serve to give users a view of how their demonstration has been generalized and what data will be available in the table once scraped.

This live programming environment is similar to that of FlashProg [@mayer2015], a framework that provides user interface support for programming-by-demonstration systems like FlashExtract [@le2014], and relates to the idea that an important quality of end-user programming is “interaction with a living system” [@zotero-60]. Hugely successful end-user programming systems such as spreadsheets and SQL provide users immediate results after entering commands. Unlike text-based commands which are only valid when complete (e.g ```SELECT * FRO``` vs ```SELECT * FROM user_table```), the target of  demonstration commands (value of DOM element under the cursor) is the same during both hover and click (incomplete command vs complete command). This allows us to take a small step further by executing a command before a user completes it, thereby providing them with a preview of the results on hover.

There are limits to this approach. Providing live feedback on websites with a large number of DOM elements or complex CSS selectors can slow down the generalization process, especially if a user is constantly moving their cursor. Furthermore, many datasets are too large to entirely preview in the table; the user might benefit more from the live feedback if it could summarize large datasets. For example, FlashProg provides a summary of the generalization through a color-coded minimap next to the scrollbar of its extraction interface.

# Related Work {#sec:related-work}

End-user web scraping for customization relates to existing work in end-user web scraping by a number of tools.

FlashProg [@mayer2015] is a framework that provides user interface support for FlashExtract [@le2014], a framework for data scraping by examples. FlashProg's interface provides immediate visual feedback about the generalization and scrapes the matched values in an output tab. In addition, it has a program viewer tab that contains a high level description of what the generated program is doing and provides a list of alternative programs. Finally, it has a disambiguation tab that utilizes conversational clarification to disambiguate programs, the conservations with the user serving as inputs to generate better programs. Though FlashProg has many desirable features we aim to implement in future iterations, it does not offer a unified environment within a browser for scraping and customizing websites.

Roussillon [@chasins2018] is a tool that enables end-users to scrape distributed, hierarchical web data. Its interface does not provide *full* live feedback about its generalizations or the values to be scrapped until all the demonstrations have been provided and the generated program has been run. If run on a website it has encountered before, Roussillon makes all the previously determined generalizations visible to the user by color-coding the values on the website that belong to the same column. This is a desirable feature for our system as users will not have to actively explore in order to discover which values are available for scraping and how they are related to each other. On the extension and repair front, Roussillon presents the web scraping code generated by demonstration as an editable, high-level, block-based language called Helena [@zotero-51]. While Helena can be used to perform more complex editing tasks like adding control flow, it presents a change in the model used for creation. Our system maintains the model used for creation by allowing users to extend and repair web scraping code via demonstration.

Vegemite [@lin2009] is a tool for end-user programming of mashups. It has two interfaces: one for scraping values from a website and another for creating scripts that operate on the scraped values. The web scraping interface does not provide live feedback about the generalization on hover but after a user clicks, the interface shows the result of the system’s generalization by highlighting the all matched values. Furthermore, even though the interface also has a table, the table is only populated with the scraped values after all the demonstrations have been provided. The scripting interface utilizes CoScripter [@leshed2008] which is used to record operations on the scraped values for automation. For example, the scripting interface can be used to demonstrate the task of copying an address in the table, pasting it into a walk score calculator and pasting the result back into the table. The script would then be generalized to all the rows and re-run to fill in the remaining walk scores. CoScripter provides the generated automation program as text-based commands, such as “paste address into ‘Walk Score’ input”, which can be edited after the program is created via “sloppy programming” [@lin2009] techniques. However, this editing does not extend to the web scraping interface used for demonstrations.

Sifter [@huynh2006] is a tool that augments well structured websites with advanced sorting and filtering functionality. Like Wildcard, it uses web scraping to extract data from websites in order to enable customizations (sorting and filtering). It performs the web scraping automatically using a variety of heuristics and solicits guidance from the user if this fails. While automatic web scraping seems desirable, it is unclear how useful it is if the goal is customization. Given a row with ten scrapable values, and therefore ten columns, would a user prefer to simply demonstrate the value for the single column they are interested in or un-demonstrate the nine values they are not interested in? This is a question we can only answer after performing  a user study.

# Conclusion And Future Work {#sec:conclusion}

In this paper, we presented our progress towards end-user web scraping for customization to empower end-users in Wildcard’s ecosystem to create, extend and repair scraping adapters. There are several outstanding issues and open questions we hope to address in future work.

Like existing approaches, web scraping in our current implementation is limited to what can be demonstrated. This is problematic if users want to scrape the URL associated with a link element, which is not visible, or only scrape a substring of a value. To solve this, we plan to harness Wildcard’s formula language. Motivated end-users will able to use formulas targeted at web scraping, for example ```=GetAttribute(link_column, ‘href’)```,  and formulas targeted at value processing, for example ```=GetSubstring(amount_column, 1, 2)```, to scrape the URL associated with columns whose values are scraped from link elements and the substring of values associated with columns whose values are strings respectively. This will give end-users some of the power available to programmers that write web scraping code in Javascript which supports a wide variety of DOM access and processing ability.

To verify our design principles, we plan to carry out a broader evaluation of our system through a user study. Furthermore, we plan to incorporate the program viewer and disambiguation features available in FlashProg [@mayer2015] to give users more insight and control into the generalization process as well as a more concrete alternative, than providing further demonstrations, to aid the generalization through disambiguation. One question we aim to ponder is whether formulas, which are in essence programs, are self-descriptive enough to not warrant paraphrasing in English as is the case with FlashExtract’s [@le2014] C# programs.

Our end goal is to empower end-users to customize websites with full control of the various aspects that are needed to enable the customizations. This in turn will help make the malleability of the web a reality for all of its users.



