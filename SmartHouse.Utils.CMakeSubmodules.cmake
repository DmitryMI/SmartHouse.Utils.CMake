function(extract_git_repo_name git_url result_var)
    # Remove the trailing .git if present
    string(REGEX REPLACE "\\.git$" "" repo_url ${git_url})
    
    # Extract the repo name from the URL
    string(REGEX MATCH "[^/]+$" repo_name ${repo_url})
    
    # Set the result variable
    set(${result_var} ${repo_name} PARENT_SCOPE)
endfunction()


function(SmartHouseSubmoduleInit submodule_url branch)
    if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
        message(STATUS "[SmartHouseSubmodule] Running from root CMakeLists.txt")
    else()
        message(STATUS "[SmartHouseSubmodule] Running as a dependency. Only root CMakeLists.txt can install submodules.")
        return()
    endif()

	string(REGEX REPLACE "\\.git$" "" submodule_url_no_git ${submodule_url})
    string(REGEX MATCH "[^/]+$" submodule_name ${submodule_url_no_git})
    message(STATUS "[SmartHouseSubmodule] Submodule name: ${submodule_name}")
    
	set(submodule_dir "dependencies/${submodule_name}")
    if(NOT EXISTS ${submodule_dir})
        message(STATUS "[SmartHouseSubmodule] Cloning submodule ${submodule_name} to ${submodule_dir}")
        execute_process(
            COMMAND git submodule add -b ${branch} ${submodule_url} ${submodule_dir}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE git_result
        )
        if(result) 
            message(FATAL_ERROR "'git submodule add' failed with code ${result}") 
        endif()

        execute_process(
            COMMAND git submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE git_result
        )

        if(result) 
            message(FATAL_ERROR "'git submodule update --init --recursive' failed with code ${result}") 
        endif()

    else()
        message(STATUS "[SmartHouseSubmodule] Updating submodule ${submodule_dir}")
        execute_process(
            COMMAND git -C ${submodule_dir} pull origin ${branch}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE git_result
        )
        if(result) 
            message(FATAL_ERROR "'git pull origin' failed with code ${result}") 
        endif()

    endif()
    
    add_subdirectory(${CMAKE_SOURCE_DIR}/${submodule_dir})
endfunction()


