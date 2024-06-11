/******************************************************************************
 * (C) Copyright 2016 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *******************************************************************************/

`ifndef UVM_MEM_MAM_CFG_NEW
`define UVM_MEM_MAM_CFG_NEW

class uvm_mem_mam_cfg_new extends uvm_mem_mam_cfg;
  rand uvm_mem_manager_pkg::new_alloc_mode_e new_mode;
endclass

`endif
