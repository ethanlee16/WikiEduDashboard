import React from 'react';
import Select from 'react-select';

const TrainingModules = React.createClass({
  displayName: 'TrainingModules',

  propTypes: {
    block_modules: React.PropTypes.array,
    editable: React.PropTypes.bool,
    all_modules: React.PropTypes.array,
    onChange: React.PropTypes.func
  },

  getInitialState() {
    let ids;
    if (this.props.block_modules) {
      ids = this.props.block_modules.map(module => module.id);
    }
    return { value: ids };
  },

  onChange(value, values) {
    this.setState({ value: values });
    return this.props.onChange(value, values);
  },

  progressClass(progress) {
    const linkStart = 'timeline-module__';
    if (progress === 'Complete') {
      return `${linkStart}progress-complete `;
    }
    return `${linkStart}in-progress `;
  },

  trainingSelector() {
    let options = _.compact(this.props.all_modules).map(module => ({ value: module.id, label: module.name }));
    return (
      <div className="block__training-modules">
        <div>
          <h4>Training modules</h4>
          <Select
            multi={true}
            name="block-training-modules"
            value={this.state.value}
            options={options}
            onChange={this.onChange}
            allowCreate={true}
            placeholder="Add training module(s)…"
          />
        </div>
      </div>
    );
  },

  render() {
    if (this.props.editable) {
      return this.trainingSelector();
    }

    let modules = this.props.block_modules.map(module => {
      let link = `/training/students/${module.slug}`;
      let iconClassName = 'icon ';
      let progressClass;
      let linkText;
      let deadlineStatus;
      if (module.module_progress) {
        progressClass = this.progressClass(module.module_progress);
        linkText = module.module_progress === 'Complete' ? 'View' : 'Continue';
        iconClassName += module.module_progress === 'Complete' ? 'icon-check' : 'icon-rt_arrow';
      } else {
        linkText = 'Start';
        iconClassName += 'icon-rt_arrow';
      }

      progressClass += ' block__training-modules-table__module-progress ';
      if (module.overdue === true) {
        progressClass += ' overdue';
      }
      if (module.deadline_status === 'complete') {
        progressClass += ' complete';
      }

      if (module.deadline_status === 'overdue') {
        deadlineStatus = `(due on ${module.due_date})`;
      }

      let moduleStatus = module.module_progress && module.deadline_status ? (
        <div>
          {module.module_progress}
          &nbsp;
          {deadlineStatus}
        </div>
      ) : (
        '--'
      );
      return (
        <tr key={module.id} className="training-module">
          <td className="block__training-modules-table__module-name">{module.name}</td>
          <td className={progressClass}>
            {moduleStatus}
          </td>
          <td className="block__training-modules-table__module-link">
            <a className={module.module_progress} href={link}>
              {linkText}
              <i className={iconClassName}></i>
            </a>
          </td>
        </tr>
      );
    });

    return (
      <div className="block__training-modules">
        <div>
          <h4>Training</h4>
          <table className="table table--small">
            <tbody>
              {modules}
            </tbody>
          </table>
        </div>
      </div>
    );
  }
}

);

export default TrainingModules;
