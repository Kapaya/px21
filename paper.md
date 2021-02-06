---
title: "Towards End-user Web Scraping For Customization"
author: "Kapaya Katongo, [Geoffrey Litt](https://www.geoffreylitt.com/) and [Daniel Jackson](http://people.csail.mit.edu/dnj/)"
bibliography: references2.bib
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
  Websites are malleable: browser extensions can be installed to customize them and browser consoles can be used to run arbitrary code on them. However, this malleability is often only accessible to programmers with knowledge of HTML, CSS, Javascript and the DOM. To tackle this, we developed an approach that empowers end-users to customize websites without traditional programming via an in-website tool called Wildcard.
  
  Wildcard’s customizations are powered by web scraping code which is currently written in Javascript by programmers. This means that end-users can only customize a website if a programmer has written web scraping code for it. Furthermore, end-users do not have the ability to extend the web scraping code in order to perform new customizations or repair the web scraping code to fix broken customizations. 
  
  In this paper, we present our progress towards a user interface within Wildcard that enables end-users to create, extend and repair web scraping code by demonstration using a live programming mechanism. We have successfully used our interface to create web scraping code by demonstration for Wildcard on a variety of websites and are hopeful that our ideas can be applied to the broader field of end-user web scraping.
---

# Introduction {#sec:introduction}

Many websites on the internet do not meet the exact needs of all of their users. This need for customization led to the creation of end-user customization systems like Chickenfoot but they mostly offered a programming model which required users to understand programming constructs such as variables and loops. 

Through what we coined “data-driven customization”, we introduced an alternative based on direct manipulation that did not require a programming model. To illustrate this, we developed a browser extension called Wildcard which augments websites with a table view that represents their underlying structured data. End-users can interact with the table via direct manipulation interactions, such as sorting, which not only manipulates the data in the table but also manipulates the parts of the website that the data represents, thus customizing it.

Wildcard aims to democratize customization of websites but it has limitations. While customizations can be achieved through high-level, direct manipulation interactions with the table view, the process of extracting the structured data for the table view requires low-level web scraping code written in Javascript. This has a number of implications:

* End-users are only able to customize a particular website if a programmer has already written the web scraping code for that website

* The customizations end-users can make to a particular website are limited to the data available in the table view with no way for them to extend it to allow new new customizations

* When web scraping code ceases to function because the website it is written for changes, the table view loses its data. This breaks the customizations dependent on the lost data, leaving end-users to wait for a programmer to fix the web scraping code

We have been inspired by existing approaches to end-user web scraping, which we contrast in [@sec:related-work], but most of them focus on extracting data out of websites and not customizing them. Web scraping for customization requires a bidirectional connection between the website and the generated table that users interact with which presents certain constraints we discuss in [@sec:implementation]. Furthermore, existing end-user web scrapers do not support demonstrations as a means for end-users to extend or repair the web scraping code that was generated via demonstrations. We strongly believe that in order for end-users to be first-class citizens in the customization ecosystem, they must have some power to easily extend and repair web scraping code. For programmers and motivated end-users for whom demonstrations are not sufficient to scrape their desired data, we briefly introduce the idea of using spreadsheet-like formulas, a hugely successful form of end-user programming, for web scraping in Section 6. Our contributions, whose design principles we explain further in Section 3, are as follows:

* We present an end-user web scraping interface for customization that utilizes a live feedback mechanism. As shown by the examples in [@sec:demos], users continuously receive live feedback about our system’s generalizations on the website as well as the values available for scraping in the table view. This helps guide their demonstrations and allows them to quickly explore the data available for performing customizations instead of having to wait to see the results of their demonstrations until they have provided all of them

* We explore the concept of “editing by demonstration” through the lens of extending and repairing web scraping code. We hypothesize that if the model used for creating is maintained during editing, new programs can be easily created by extending existing programs and existing programs become easier to repair thus making them useful for longer. We provide examples of how end-users can extend and repair web scraping code in [@sec:demos]


# Demos {#sec:demos}

In this section, we provide examples of how our interface can be used by end-users to create, extend and repair web scraping code for Wildcard.

## Creating Web Scraping Code

*www.weather.com*

Jane wants to customize her experience on www.weather.com by sorting the ten day forecast by the description of the weather on each day. This will let her quickly view all the days with similar weather descriptions and allow her to plan when to go for an outdoor run. Wildcard currently does not support this because a programmer has not written the required web scraping code. Using our interface, Jane can create web scraping code by demonstration that will enable her to customize the website.

When Jane initiates the web scraping process, a control region is added to the top of the website which provides brief instructions and buttons for various actions. When she hovers her cursor over the desired data, the following happens: 

1. The website element that corresponds to the row that the value belongs to is highlighted with a green border. This signals to the her that further scraping actions can only be performed for values in this row

2. The website elements that correspond to the value and its equivalents in the other rows are highlighted with a green background. These represent a column of that data

3. Wildcard’s table view appears and is populated with the values that will be scraped from the highlighted column values.

<video controls="controls" muted="muted" src="media/2.1.1.mp4" muted playsinline controls class>
</video>

Jane explores other desired data and the interface continuously provides feedback about what the result of her scraping actions will be and how the system is generalizing from the demonstrations. Once Jane commits her scraping action, the column is saved and a new one is automatically created in the control region to show which column in the table the data of the next values will be scrapped into.

<video controls="controls" muted="muted" src="media/2.1.2.mp4" muted playsinline controls class>
</video>
 
She proceeds to demonstrate values for column B and then hovers over the previously demonstrated value to reveal which column it belongs to in the control region. She ends the web scraping process and customizes the website through the Wildcard table view to sort the forcast by the weather description, a feature which the developers of the website did not anticipate. 

<video controls="controls" muted="muted" src="media/2.1.3.mp4" muted playsinline controls class>
</video>

*www.csail.mit.edu*

John wants to customize his experience on www.csail.mit.edu/people by sorting the list of principal researchers in MIT’s Computer Science and Artificial Intelligence Lab (CSAIL). Since this is currently not supported by Wildcard, he initiates our web scraping interface. He demonstrates “Hal Abelson” to scrape the names of principal researchers but before proceeding to demonstrate “hal@mit.edu” he notices that the third row in the table does not have the expected entry of “Anant Agarwal” and that the value is not highlighted along with the other names when he hovers over “Hal Abelson”. Further scrolling through the table reveals that the sixteenth, thirty fifth and other rows do not have values in column A.

<video controls="controls" muted="muted" src="media/2.2.1.mp4" muted playsinline controls class>
</video>

This signals to John that he needs to aid the system’s generalization. He starts by clicking on the square in the control region with the label A to make it the active column. This highlights all the known rows on the page with a green border which alerts John that he can provide further demonstrations of the desired data from them and not just the first row. He proceeds to demonstrate “Anant Agarwal” which fills in his entry in the table. Further scrolling through the table reveals that the sixteenth, thirty fifth and other previously empty rows also have values.

<video controls="controls" muted="muted" src="media/2.2.2.mp4" muted playsinline controls class>
</video>

Now that the column is as expected, John switches back to column B and proceeds to demonstrate the rest of the desired data. After customizing the page, he has the list of principal researchers sorted by the descriptions of their research interests, a feature that the developers of the website did not anticipate.

<video controls="controls" muted="muted" src="media/2.2.3.mp4" muted playsinline controls class>
</video>

## Extending Web Scraping Code

*www.timeanddate.com*

Alice uses Wildcard to customize her experience on www.timeanddate.com/holidays/us. By sorting column C in the table view, she is able to see the list of holidays and observances in the United States in 2021 sorted by the day of the week on which they occur. This enables her to easily view all the holidays that occur on Fridays in order to plan socially distant hiking trips with her friends.

<video controls="controls" muted="muted" src="media/2.3.1.mp4" muted playsinline controls class>
</video>

Alice realizes that it would also be useful for her to be able to also sort the list by the type of holiday. This would let her easily view all the federal holidays together for example. Without our interface, Alice would have to reach out to the programmer who wrote the web scraping code for the website in order for them to update it to scrape the holiday types. Using our interface, Alice can extend the web scraping code by herself.

She initiates the editing process and is guided to the row that she needs to interact with by the green outline. As she hovers over the scraped values, the columns they belong to are highlighted. Finally,  she clicks on “Federal Holiday” to scrape the holiday type values and saves the scraper. Alice proceeds to sort the list by the type of holiday without having sought the assistance of a programmer.

<video controls="controls" muted="muted" src="media/2.3.2.mp4" muted playsinline controls class>
</video>

## Repairing Web Scraping Code

*scholar.google.com*

Bob uses Wildcard to customize his experience on scholar.google.com/citations which supports sorting publications by their citation count and the year that they were released in but not by their title. Wildcard’s sorting customization allows him to easily sort publications by their title which he finds very useful when looking for a publication by an author that he only knows by title.

<video controls="controls" muted="muted" src="media/2.4.1.mp4" muted playsinline controls class>
</video>

Unfortunately for Bob, the customization has not been working since scholar.google.com/citations got a minor redesign as seen by the missing data in column A of the table. Without our interface, Bob would have to reach out to the programmer who wrote the web scraping code for the website in order for them to fix it and get his customization working again. Using our interface, Bob can fix the web scraping code himself.

He initiates the editing process and is guided to the row that she needs to interact with by the green outline. He hovers over the desired value to demonstrate the column he wants to scrape but from the control region and table notices that the values will be populated into column D and not A where it was. Bob makes column A the active column, commits his scraping action and sees the publication titles populated into column A of the table. Bob saves and proceeds to re-apply his customization to the website by sorting the publications by their title, all without having sought the assistance of a programmer.

<video controls="controls" muted="muted" src="media/2.4.2.mp4" muted playsinline controls class>
</video>

# Design Principles {#sec:design-principles}


Our implementation of end-user web scraping is inspired by the end-user programming literature and existing end-user web scraping approaches but we specifically focus on the process and experience of creating, extending and repairing web scraping code. Below, we discuss the design principles that guided us with the hope that they can be applied more broadly to the field of end-user web scraping.

## Exploratory Web Scraping

Existing approaches to end-user web scraping have harnessed programming by demonstration to eliminate the iterative and tedious process of inspecting website internals to discover the selectors needed to scrape the desired data. This has enabled end-users to easily perform the previously complex task without having to know about web technologies like HTML, CSS, Javascript and the DOM. In spite of these advances in moving web scraping away from traditional programming, one key aspect has not progressed: the write-compile-debug cycle. Users typically have to perform all of their demonstrations before they get to see the system's generalizations and the scraped values, repeating the process if the results are not satisfactory. This is analogous to writing, compiling and debugging code which, from our experience and preliminary tests, hinders exploration of values available for scraping.

To tackle this, we employ live programming techniques to eliminate the write-compile-debug cycle. As we show in [@sec:demos], when users hover over values they wish to provide as a demonstration they immediately get feedback in the website. Our interface shows how our system will generalize the user’s demonstration across the other rows of the data and shows a preview of what values will be scraped into the table view. We believe that this is particularly important for the end goal of customization as it allows users to easily and quickly explore the values available for scraping which will form the basis of their customizations.

Our live feedback mechanism is similar to that of FlashExtract and  relates to the idea that an important quality of end-user programming is “interaction with a living system”. The authors describe how hugely successful end-user programming systems such as spreadsheets and SQL provide users immediate results after entering commands. Unlike text-based commands which are only valid when complete (e.g “SELECT * FRO” vs “SELECT * FROM user_table”), the target of  demonstration commands (value of DOM element under the cursor) is the same during both hover and click (incomplete command vs complete command). This recognition coupled with the property of scraping functions being pure functions allows us to take a small step further by executing a command before a user completes it thereby providing them with a preview of the results.

The live feedback mechanism which powers our exploratory web scraping has its limits. Providing live feedback on websites with a large number of DOM nodes or complex CSS selectors can slow down the generalization process, especially if users are constantly moving their cursor. The cursor’s interactions with DOM elements on a website serves as the primary input for our generalizations. Furthermore, live feedback is most relevant when scraping a website that has all of the desired data loaded. If some of the data is not available (users need to scroll or page through a table to load the rest), the preview of the generalization and scraped values is not complete and as such might not be as useful. 

## Editing By Demonstration

The data in Wildcard’s table view forms the basis of its customizations. In turn, the web scraping code that extracts that data from it’s website forms the basis of the table view. The customizations end-users can make to a website are therefore tightly coupled with the underlying web scraping code. If the web scraping code ceases to function because the website changes, the table view may lose its data which means that an end-user’s customizations may also cease to function. Furthermore, end-users are powerless to extend the web scraping code to add columns to the table view in order to perform new customizations. If Wildcard is to truly democratize customization, end-users should have some power to repair and extend web scraping code.

Editing by demonstration promises to fulfil this goal. We have yet to formally study this but we believe that if users can create web scraping code by demonstration, it is not unreasonable to expect them to be able to extend or repair it by demonstration where feasible. To achieve this, we maintain the same user interface utilized for the creation process. The edit process simply boots up the interface using metadata stored with the web scraping code to restore it to the state when the demonstration was completed. Therefore, users that have gone through the creation process will immediately realize what to do in order to extend or repair the code. Users that have not gone through the creation process and experienced our interface might have a harder time but we hope that the visual clues (such as highlighting the row to perform demonstrations from with a green border) and our live feedback mechanism (immediately preview the results of their demonstrations) will serve as sufficient guides. 

If end-users can easily repair web scraping code, it becomes more maintainable and so do the customizations that it powers. If end-users can easily extend web scraping code, newer versions of it become more abundant which increases the possible customizations that can be made. In some sense, editing by demonstration gives end-users the power to program the programs (web scraping code) that they use for programming (making customizations). As an item of future work, we are keen to explore whether this idea can be applied to programming by demonstration implementations beyond web scraping. 

Our decision to enable editing by demonstration, and not by a programming model for example, is related to the idea of “in-place toolchains” being an integral part of end-user programming systems. The authors champion the practice of end-user programming systems allowing users to edit programs “using an interface and set of abstractions that is as close as possible to the ones they use for their regular daily work”. Our editing interface doesn’t quite meet this standard yet but in Section 6 we briefly describe how we are working towards blurring the line between customizing and web scraping by using the table view as the foundation for both. 

Editing by demonstration in the web scraping domain is feasible because the programs that scrape column values are independent of each other: changing the program that scrapes values into column A has no effect on the program that scrapes values in column B. However, editing programs that have dependencies on other programs or are dependent on by other programs is not feasible. For example, changing the program that retrieves a row would affect the programs that scrape values into columns because they are dependent on the values being available in the row. This is an acceptable limitation for us given our focus on extension and repair which only deal with programs that scrape column values.

# System Implementation {#sec:implementation}

We implemented our end-user web scraping interface within Wildcard. The output of the interface is a configuration object referred to in Wildcard as a DOM scraping adapter. DOM scraping adapters fulfil the standard task of scraping data from a website and the customization specific task of maintaining a bidirectional connection between the website and the table view. The bidirectional connection is achieved by obtaining references to the DOM elements that correspond to rows and columns in the table view. For example, when a user sorts the table view, the DOM elements that represent the table rows are moved around in the DOM to reflect the new sorted order. More details about DOM scraping adapters can be found in the Wildcard paper.

Our interface takes up the task of determining the row and column element selectors needed by DOM scraping adapters that was previously performed by programmers. This is achieved through standard wrapper induction methods that are similar to those of Sifter and Vegemite except in one major regard: in order for a row element selector to be a valid candidate, all the elements that it selects must be direct siblings. This is important for the end goal of customization because row elements that are not direct siblings may not represent data on the website that should be related as part of the same table by operations such as sorting. Take the following made up DOM structure:

```html
<html>
    <header>
        <title> Avengers Civil War Teams </title>
    </header>
    <body>
        <h1> Team Iron Man </h1>
        <div>
            <div class='avenger'>
                <span class='super_hero_name'> Iron Man </span>
            </div>
            <div class='avenger'>
                <span class='super_hero_name'>  Black Widow </span>
            </div>
            <div class='avenger'>
                <span class='super_hero_name'> War Machine </span>
            </div>
        </div>
        <h1> Team Captain America </h1>
        <div>
            <div class='avenger'>
                <span class='super_hero_name'> Captain America </span>
            </div>
            <div class='avenger'>
                <span class='super_hero_name'>  Scarlet Witch </span>
            </div>
            <div class='avenger'>
                <span class='super_hero_name'> Winter Soldier </span>
            </div>
        </div>
    </body>
</html>
```

The DOM structure contains two tables of data (Team Iron Man and Team Captain America). Without the constraint that row elements have to be direct siblings, the row generalization algorithm would determine the row selector to be ```.avenger```. While this may be the correct result for the task of extraction, it is never for the task of customization. The selector matches all rows across the two tables so the sorting customization, for example, could place rows in the incorrect table and thereby distort what the tables represent. Because of this, our interface currently does not support generalizing over such DOM structures but we plan to explore the possibility of extracting multiple tables from a website and joining them. 

Another DOM structure that our interface cannot currently generalize over is one in which column elements are not contained within a row element that is a direct sibling of all the other row elements. Take the following made up DOM structure:

```html
<html>
    <header>
        <title> Avengers </title>
    </header>
    <body>
        <h1 class='super_hero_name'> Iron Man </h1>
        <span class='real_name'> Real Name: Tony Stark </span>
        <h1 class='super_hero_name'> Captain America </h1>
        <span class='real_name'> Real Name: Steven Rogers </span>
        <h1 class='super_hero_name'> Black Widow </h1>
        <span class='real_name'> Real Name: Natalia Romanoff </span>
    </body>
</html>
```

The DOM structure contains one table of data in which rows are made up of an H1 tag (super hero name) and a SPAN tag (real name). For the task of extraction, the DOM elements can be scraped using the shown classes to output a table in which the values of the H1 tags form the first column and the values of the SPAN tag form the second column. For the task of customization, Wildcard would need to know what the row boundaries are in order for customizations such as sorting to not distort the representation of the website. This can be done in DOM scraping adapters written by a programmer in Javascript by creating artificial row boundaries. In the above DOM structure, an artificial row boundary could be created by representing a row as an H1 tag and the SPAN tag that immediately follows it. These artificial rows would be treated as a single unit which would not distort the website after a sorting customization. We plan to explore how artificial row boundaries can be created by end-users via demonstration in order to support such DOM structures which are not uncommon (HackerNews has this structure).

The live feedback mechanism is implemented by continuously running the generalization algorithms on the DOM element under the user’s cursor. This is possible because the associated operations can be run repeatedly with no side effects i.e. they are pure functions. The generated row and column selectors are used to create a DOM scraping adapter and highlight all the matching elements on the page. The DOM scraping adapter is executed to populate the table view and set up the bidirectional connection. This means that users can actually customize as they scrape if so desired but we are yet to explore the possibilities that customizing while scraping offer, if any. 

The implementation of the editing by demonstration feature is rather simple. DOM scraping adapters are generated with metadata that can be used to both boot up the demonstration interface. In our case, the metadata simply consists of the row element selector and the column element selectors. We are keen to explore what other implementations of programming by demonstration this can be done for and what the implications and benefits would be.


# Related Work {#sec:related-work}

Our live end-user web scraping for customization relates to existing work in end-user web scraping by a number of tools.

FlashExtract’s live feedback mechanism is the most similar to our goal of making the web scraping process exploratory. Its interface provides immediate feedback about the generalization and scrapes the matched values in an output tab. In addition, the interface has a program viewer tab that contains a high level description of what the generated program is doing and provides a list of alternative programs. Finally, the interface has a disambiguation tab that utilizes conversational clarification to disambiguate programs, the conservations with the user serving as inputs to generate better programs. Both the program viewer and disambiguation features are not currently available in our interface but we hope to have implementations of them in future iterations. Where we differentiate ourselves from FlashExtract is by allowing end-users to extend and repair web scraping code by demonstration although it is not clear whether there are significant barriers to FlashExtract providing these features.

Roussillon’s interface does not provide live feedback about its generalizations or the values to be scrapped until all the demonstrations have been provided and the generated program has been run. If run on a website it has encountered before, Roussillon makes all the previously determined generalizations visible to the user by color-coding the values on the website that belong to the same column. This is certainly worth considering for our interface as users will not have to actively explore to discover which values are available for scraping and how they are related to each other. On the extension and repair front, Roussillon presents the web scraping code generated by demonstration as an editable, high-level, block-based language called Helena. Users can move code blocks around to change the order of columns in the output but the blocks cannot be used to add new demonstrations or repair existing ones.

Vegemite has two interfaces: one for scraping values from a website and another for creating scripts that operate on the scraped values. The web scraping interface does not provide live feedback about the generalization on hover but after a scraping action is committed (click on value to scrape) the interface shows the result of the system’s generalization by highlighting the all matched values. Furthermore, even though the interface has a table view like our interface does, the table is only populated with the scraped values after all the demonstrations have been provided. The scripting interface utilizes CoScripter and is used to record operations on the scraped values for automation. For example, the scripting interface can be used to demonstrate the task of copying an address in the table, pasting it into a walk score calculator and pasting the result back into the table. The task would be generalized to all the rows and re-run to fill in the remaining walk scores.  CoScripter provides the generated automation program as text-based commands, such as “paste address into ‘Walk Score’ input”, which can be edited after the program is created via “sloppy programming” techniques. However, this editing does not extend to the web scraping interface used to demonstrate the web scraping.

Sifter, like Wildcard, uses web scraping to extract data from websites in order to enable its customizations (sorting and filtering). It performs the web scraping automatically using a variety of heuristics and solicits guidance from the user if this fails. While automatic web scraping seems desirable, it is unclear how useful it is if the goal is customization. Given a row with ten scrapable values, and therefore ten columns, would a user prefer to simply demonstrate the value for the single column they are interested in or un-demonstrate the nine values they are not interested in? This is a question we can only answer after performing  a user study.

# Conclusion And Future Work {#sec:conclusion}

In this paper, we presented our progress towards end-user web scraping to empower end-users in Wildcard’s ecosystem to create, extend and repair web scraping code. There are several outstanding issues and open questions we hope to address in future work.

Like existing approaches, web scraping in our current implementation is limited to what can be demonstrated. This is problematic if users want to scrape the URL associated with a link, which is not visible, or only scrape a substring of a value. To solve this, we plan to harness Wildcard’s spreadsheet-like formula language. This will blur the line between customizing and web scraping with the table serving as the basis of both. Formulas targeted at web scraping, for example ```=GetAttribute(columnName, attributeName)```, can be used with formulas targeted at value processing, for example ```=GetSubstring(columnName, startIndex, endIndex)```,  to bridge the gap between end-user web scraping and traditional, script-based web scraping which allows for a wide variety of operations to scrape and process values. More broadly, we are considering whether the table view can be used as a framework for building data-driven customizable websites and not just making data-driven customizations. This idea relates to a body of work that explores using spreadsheets to build websites .

To verify our design principles, we plan to carry out a broader evaluation of our interface through a user study. So far our design principles have been led by personal experience and preliminary tests with other researchers in our group and friends and family. Furthermore, we hope to incorporate the program viewer and disambiguation features available in FlashExtract to give users more insight and control into the generalization process as well as a more concrete alternative, than providing further demonstrations, to aid the generalization through disambiguation. One question we aim to ponder is whether formulas, which are in essence programs, are self-descriptive enough to not warrant paraphrasing in English as is the case with FlashExtract’s programs as seen in its program viewer. 

Our end goal is to empower end-users to customize websites with full control of the various aspects that are needed to enable the customizations. This in turn will help make the malleability of the web a reality for all of its users.
